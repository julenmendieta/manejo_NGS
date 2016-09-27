#!/bin/bash 
#$ -N chr_a_vcf
##$ -q croms.q@crom04
##$ -l h_vmem=10G 
#$ -o /home/biomedicina1/hoenicka/Merlin/prueba2/vcfs
#$ -e /home/biomedicina1/hoenicka/Merlin/prueba2/vcfs
##$ -m beas
##$ -M 
##$ -pe smp 8
# Script para anyadir chr a la posicion de los cromosomas en ficheros vcf

. /opt/soft/modules/modules-3.2.8/Modules/3.2.8/init/bash 
shopt -s expand_aliases

dir=/home/XXXXXXXX
dir2=/home/ZZZZZZZ
# Primero borramos los indices
# rm $dir"/"*idx
ficheros=`ls $dir"/"*vcf`
mkdir -p $dir"/"vcfs_chr

# Generamos el fichero que indica donde estan los vcf
touch $dir"/vcfs_chr/dirvcf.txt"

for fich in $ficheros
do
	indiv=`basename $fich`
	fich_salida=`echo $indiv | sed 's/\.vcf/_chr\.vcf/g'`
	# Guardamos la cabecera en un fichero a parte para cambiar el ID de los contigs y anyadir chr luego
	grep "^#" $fich > $dir"/"$fich_salida"_temp"
	# Guardamos los contigs, y nos quedamos con los q no son numeros. Los numeros ya sabemos que empezaran
	# por 1, 2, 3, 4, 5, 6 ,7 ,8 y 9
	contigs=`grep -v "^#" $fich | cut -f1 | uniq`
	contigs=`echo $contigs | grep -o [^0-9]`
	contigs=`echo $contigs ; seq 1 9`
	# Primero cambiamos la cabecera
	for con in $contigs
	do
		sed "s/contig=<ID=$con/contig=<ID=chr$con/g" $dir"/"$fich_salida"_temp" > $dir"/vcfs_chr/"$fich_salida
		cat $dir"/vcfs_chr/"$fich_salida > $dir"/"$fich_salida"_temp"
	done
	# Despues el resto del vcf
	awk '{if($0 !~ /^#/) print "chr"$0; else print $0}' $fich >> $dir"/vcfs_chr/"$fich_salida
	# Borramos el fichero temporal
	rm $dir"/"$fich_salida"_temp"
	# Anyadimos el fichero a la lista
	echo $dir"/vcfs_chr/"$fich_salida >> $dir"/vcfs_chr/dirvcf.txt"
done


