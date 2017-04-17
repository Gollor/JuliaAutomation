# JuliaAutomation

## Summary

This server is designed to use with a computer cluster to automate tasks and manage resources. It also has the basic tools to monitor the cluster and gather information about nodes in order to manage and balance the load.

## Usage

To start the server run the next command in the console while at project root folder:

```
mkdir build
cd build
julia run.jl
```

After this the server will start.

## Cluster

The server accepts any Linux machines with enabled ssh service as the nodes of the cluster. The machines may or not be physically or logically combined into a one processing system.
To add machines to the cluster the server requires ssh credentials. They could be entered manually or supplied via .pem files.
To supply machines create the file "instances.csv" in the build folder and enter pairs {"user@host", gpu_id} in the csv format.

## Tasks

The tasks are characterized by the two components - the files that are required to complete the task and the arguments to launch the executable file. Alternatively the executable could be replaced with Julia function.
To supply tasks create the file "tasks.csv" in the build folder and enter pairs {id, "command"} in the csv format. All args defined as "$gpu" will be replaced with "/gpu:{}" strings depending on the node.

## Logging

The server is able to capture output of executables and access their log files in order to store logging information on the master machine. The special function of logging is to control the execution of tasks. If the process fails to update its logs in time or outputs specific patterns the server may understand was the task completed and should it be rerun.

## Development

Currently the server is in the initial stage of the development. It has only the basic features and should be used with care.
