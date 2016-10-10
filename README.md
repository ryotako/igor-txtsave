# igor-txtsave
Save waves in Igor Pro as textfiles

## Functions
- `TxtSave(wFolder,wList,fName [option])`
- `TxtSave_Recursive(wFolder,wList,fName [ignore,option])`

`TxtSave` is just a wrapper function for `Save` operation.
When you work in `experiment.pxp`, textfiles are saved in a directory `experiment_txtfiles`.
```
TxtSave("root:folder1","dataX;dataY","data.txt")
// Execute the following:
// cd root:folder1
// Save/B/G/O/W/M=[LF in your OS]/P=[automatically determined path] "dataX;dataY" as "data.txt"
```

`TxtSave_Recursive` apply `TxtSave` under `wFolder` recursively.
The next code saves all waves named dataX and dataY in the experiment file except for waves under `root:Packages` 
```
TxtSave_Recursive("root:","dataX;dataY","data.txt",ignore="root:Packages",option="/J/O")
```

## Options
- `ignore`
You can select data folders to ignore with `ignore` option. The format of `ignore` option is just like .gitignore.

- `option`
You can set options of `Save` operation explicitly with this `option` option.
When you do not set this option, options `/G/O/W/M="\n"` are used for `Save` operation.
(When you use Windows, deafult option is `/G/O/W/M="\r\n"`)
You cannot use options `/B` and `/P` because these options are automatically chosen by this procedure.
