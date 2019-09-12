
# etl

* Verify that the graph files were mounted

```
$ dc exec etl bash -c "ls -lR  /etl/outputs  | wc -l"
```

* Verify that the manifest was mounted

```
$ dc exec etl bash -c "ls -l /etl/bmeg_file_manifest.txt"
```

* Exec into the etl container, run the script

```
$ dc exec etl bash
# cd /etl
# load_database.sh <graph-name> bmeg_file_manifest.txt
```

* Run integration tests

```
cd /etl/bmeg-etl
BMEG_URL=grip:8201 BMEG_GRAPH=<graph-name> BMEG_CREDENTIAL_FILE=  pytest tests/integration
```
