for dir in */; do
    cd "$dir"

    for mol2 in *.mol2; do
        acpype -i "$mol2" -c gas
    done
    wait

    # Mendapatkan ID ligan
    mol_files=(*.mol2)  # Menyimpan daftar file .mol2 dalam array mol_files
    lig1=$(basename "${mol_files[0]}" .mol2)
    lig2=$(basename "${mol_files[1]}" .mol2)
    lig1_id=$(awk 'NR==4{print $4}' "${lig1}.acpype/${lig1}_NEW.pdb")
    lig2_id=$(awk 'NR==4{print $4}' "${lig2}.acpype/${lig2}_NEW.pdb")

    file1="${lig1}.acpype/${lig1}_GMX.itp"
    file2="${lig2}.acpype/${lig2}_GMX.itp"

    # Membuat file complex.itp
    output1=$(awk '/\[ atomtypes \]/{flag=1} !a[$0]++ && !flag' "$file1" "$file2")
    output2=$(awk '/\[ atomtypes \]/{flag=1} /\[ moleculetype \]/{flag=0} flag' "$file1" "$file2" | awk '!a[$0]++')
    output2=$(echo "$output2" | sed '/^$/d')
    output3=$(awk '/\[ moleculetype \]/{flag=1} flag' "$file1")
    output4=$(awk '/\[ moleculetype \]/{flag=1} flag' "$file2")
    echo "$output1" > "complex.itp"
    echo >> "complex.itp"
    echo "$output2" >> "complex.itp"
    echo >> "complex.itp"
    echo "$output3" >> "complex.itp"
    echo >> "complex.itp"
    echo "$output4" >> "complex.itp"
    sed -i "s/lig1/$lig1_id/g" "complex.itp"
    sed -i "s/lig2/$lig2_id/g" "complex.itp"
    echo "File complex.itp berhasil dibuat."
    wait

    # Membuat file topol.top
    echo "; topol.top created by ladock (v: 2023) on $(date)" > "topol.top"
    echo >> "topol.top"
    echo "; Include forcefield parameters" >> "topol.top"
    echo "#include \"amber99sb-ildn.ff/forcefield.itp\"" >> "topol.top"
    echo >> "topol.top"
    echo "; Include complex topology" >> "topol.top"
    echo "#include \"complex.itp\"" >> "topol.top"
    echo >> "topol.top"
    echo "; Include water topology" >> "topol.top"
    echo "#include \"amber99sb-ildn.ff/tip3p.itp\"" >> "topol.top"
    echo >> "topol.top"
    echo "#ifdef POSRES_WATER" >> "topol.top"
    echo "; Position restraint for each water oxygen" >> "topol.top"
    echo "[ position_restraints ]" >> "topol.top"
    echo "   1    1       1000       1000       1000" >> "topol.top"
    echo "#endif" >> "topol.top"
    echo >> "topol.top"
    echo "; Include topology for ions" >> "topol.top"
    echo "#include \"amber99sb-ildn.ff/ions.itp\"" >> "topol.top"
    echo >> "topol.top"
    echo "[ system ]" >> "topol.top"
    echo "$lig1 & $lig2" >> "topol.top"
    echo >> "topol.top"
    echo "[ molecules ]" >> "topol.top"
    echo "$lig1_id                  1" >> "topol.top"
    echo "$lig2_id                  1" >> "topol.top"
    echo "File topol.top berhasil dibuat."
    wait

    # Membuat file complex.pdb
    grep -h ATOM "${lig1}.acpype/${lig1}_NEW.pdb" "${lig2}.acpype/${lig2}_NEW.pdb" > complex.pdb
    echo "File complex.pdb berhasil dibuat."
    wait

    # generate box
    gmx editconf -f complex.pdb -o box.pdb -bt triclinic -d 0.8 -c
    wait

    # solvation
    gmx solvate -cp box.pdb -cs spc216.gro -p topol.top -o solv.gro
    wait

    # ionization
    gmx grompp -f ../ions.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 1 && \
    echo -e "5" | gmx genion -s ions.tpr -o ions.gro -p topol.top -pname NA -nname CL -neutral
    wait

    # minimization
    gmx grompp -f ../em.mdp -c ions.gro -p topol.top -o em.tpr -maxwarn 1 && \
    gmx mdrun -v -deffnm em && \
    echo -e "10\n0" | gmx energy -f em.edr -o potential.xvg
    wait

    # posre ligand
    echo -e "2\nq" | gmx make_ndx -f "${lig1}.acpype/${lig1}_NEW.pdb" -o "${lig1_id}.ndx"
    echo -e "3\nq" | gmx genrestr -f "${lig1}.acpype/${lig1}_NEW.pdb" -n "${lig1_id}.ndx" -o "${lig1_id}.itp" -fc 1000 1000 1000
    echo -e "2\nq" | gmx make_ndx -f "${lig2}.acpype/${lig2}_NEW.pdb" -o "${lig2_id}.ndx"
    echo -e "3\nq" | gmx genrestr -f "${lig2}.acpype/${lig2}_NEW.pdb" -n "${lig2_id}.ndx" -o "${lig2_id}.itp" -fc 1000 1000 1000
    wait

    # make index system
    echo -e "2 | 3\nq" | gmx make_ndx -f em.gro -o index.ndx
    wait

    # Menyalin file mdp
    cp ../md.mdp .
    cp ../nvt.mdp .
    cp ../npt.mdp .

    # Mengganti teks "Protein_LIG" menjadi "$lig1_id_$lig2_id"
    sed -i "s/Protein_LIG/${lig1_id}_${lig2_id}/g" nvt.mdp
    sed -i "s/Protein_LIG/${lig1_id}_${lig2_id}/g" npt.mdp
    sed -i "s/Protein_LIG/${lig1_id}_${lig2_id}/g" md.mdp

    # NVT
    gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr -maxwarn 5 && \
    gmx mdrun -v -s nvt.tpr -deffnm nvt
    wait

    # NPT
    gmx grompp -f npt.mdp -c nvt.gro -t nvt.cpt -r nvt.gro -p topol.top -n index.ndx -o npt.tpr -maxwarn 5 && \
    gmx mdrun -v -s npt.tpr -deffnm npt
    wait

    # Production
    gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -n index.ndx -o md.tpr -maxwarn 5 && \
    gmx mdrun -v -s md.tpr -deffnm md
    wait

    cd ..
done
