#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
		printf "Illegal number of parameters.\n\n"
		printf "Usage:\n	load_database.sh <graph> <file_manifest>\n"
		exit 1
fi

graph=$1
file_manifest=$(realpath $2)
release_dir=$(dirname $file_manifest)

echo "linking $release_dir to ./outputs"
ln -s $release_dir outputs

echo "checking that all files in the manifest exist"
for f in $(cat $file_manifest); do
		if [ ! -f $f ]; then
				echo "file $f does not exist!"
				exit 1
		fi
done

while true; do
    read -p "Do you wish to drop the graph before proceeding with the database load? " yn
    case $yn in
        [Yy]* ) echo "dropping graph: $graph"; grip drop $graph --host grip:8202; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ensure graph exists
grip create $graph --host grip:8202
echo "Created graph. " $graph


gofast="-n 24 --database grip --mongo-host mongodb://mongo"

for f in $(cat $file_manifest | grep "Vertex"); do
	grip mongoload ${graph} $gofast --vertex $f
done

for f in $(cat $file_manifest | grep "Edge"); do
	grip mongoload ${graph} $gofast --edge $f
done

echo "removing soft link ./outputs"
rm outputs
