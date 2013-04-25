# code_standard_checker

A tool to run phpcs on a project and get statistics

## Full Report

The full report runs over a given directory (or `/www/files` by default) and counts files, lines of code, and coding standard violations
outputting a simple ascii report.

If you would like to run this automatically, consider keeping a separate checkout of the code just for this purpose and running against it with
the `-u` flag to automatically update the code to the latest on the current remote tracking branch:

```sh
./fullreport.sh -u /path/to/codebase
```
