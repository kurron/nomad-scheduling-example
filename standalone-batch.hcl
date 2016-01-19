job "standalone-batch" {
    // Controls if the entire set of tasks in the job must be placed atomically or if they can be scheduled incrementally.
    all_at_once = false

    // A list of datacenters in the region which are eligible for task placement. This must be provided, and does not have a default.
    datacenters = ["my-datacenter"]
    
    // Annotates the job with opaque metadata.
    meta {
        jobKey = "job value"
    }

    // Specifies the job priority which is used to prioritize scheduling and access to resources. Must be between 1 and 100 
    // inclusively, and defaults to 50.
    priority = 50

    // The region to run the job in, defaults to "global".
    region = "USA"

    // Specifies the job type and switches which scheduler is used. Nomad provides the service, system and batch schedulers, 
    // and defaults to service. 
    type = "batch"

    // Specifies the task's update strategy. When omitted, rolling updates are disabled.
    update {
        // Specifies the number of tasks that can be updated at the same time.
        max_parallel = 1

        // Delay between sets of task updates and is given as an as a time duration. If stagger is provided as an integer, 
        // seconds are assumed.  Otherwise the "s", "m", and "h" suffix can be used, such as "30s".
        stagger = "30s"
    }

    // This can be specified multiple times, to add a task to the job.
    task "echo-environment" {

        // Specifies the task driver that should be used to run the task.
        driver = "docker"

        constraint {
            distinct_hosts = true
        }

        // A map of key/value configuration passed into the driver to start the task. The details of configurations are 
        // specific to each driver.
        config {
            image = "ubuntu:latest"
            command = "/bin/bash"
            args =["echo", "$nomad.ip", "$DATACENTER", "$PROFILE"]
            labels {
                realm = "Experiment"
                managed-by = "Nomad"
            }
            priviledged = false
            ipc_mode = "none"
            pid_mode = ""
            uts_mode = ""
            network_mode = "host"
#           host_name = "does not make sense when using host networking"
            dns_servers = ["8.8.8.8", "8.8.4.4"] 
            dns_search_domains = ["kurron.org", "transparent.com"] 
            port_map {}
            auth {}
        }

        // A map of key/value representing environment variables that will be passed along to the running process. Nomad variables 
        // are interpreted when set in the environment variable values. See documentation for the table of interpreted variables.
        env {
            // example of an interpreted variable
            DATACENTER = "$node.datacenter"

            // example of an unintepreted variable
            PROFILE = "test"
        }

        // Provides the resource requirements of the task. 
        resources {
            // The CPU required in MHz.
            cpu = 500

            // The disk required in MB.
            disk = 256

            // The number of IOPS required given as a weight between 10-1000.
#           iops = 500

            // The memory required in MB.
            memory = 512

            // The network required.  
            network {
                // The number of MBits in bandwidth required.
                mbits = 100
            }
        }

        // Annotates the task group with opaque metadata.
        meta {
            taskKey = "task value"
        }

        // A time duration that can be specified using the s, m, and h suffixes, such as 30s. It can be used to configure the time 
        // between signaling a task it will be killed and actually killing it.  
        kill_timeout = "30s"
    }
}