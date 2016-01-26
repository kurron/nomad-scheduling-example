job "standalone-service" {
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
    type = "service"

    // Restrict our job to only linux. We can specify multiple constraints as needed.
    constraint {
        attribute = "$attr.kernel.name"
        value = "linux"
    }

    // Specifies the task's update strategy. When omitted, rolling updates are disabled.
    update {
        // Specifies the number of tasks that can be updated at the same time.
        max_parallel = 1

        // Delay between sets of task updates and is given as an as a time duration. If stagger is provided as an integer, 
        // seconds are assumed.  Otherwise the "s", "m", and "h" suffix can be used, such as "30s".
        stagger = "30s"
    }

    // This can be specified multiple times, to add a task to the job.
    task "web-server" {

        // Specifies the task driver that should be used to run the task.
        driver = "docker"

        constraint {
            distinct_hosts = true
        }

        // A map of key/value configuration passed into the driver to start the task. The details of configurations are 
        // specific to each driver.
        config {
            image = "nginx:latest"
            labels {
                realm = "Experiment"
                managed-by = "Nomad"
            }
            priviledged = false
            ipc_mode = "none"
            pid_mode = ""
            uts_mode = ""
            network_mode = "bridge"
#           host_name = "does not make sense when using host networking"
            dns_servers = ["8.8.8.8", "8.8.4.4"] 
            dns_search_domains = ["kurron.org", "transparent.com"] 
            port_map {
                insecure = 80
                secure = 443
            }
            auth {}
        }

        // Nomad integrates with Consul for service discovery. A service block represents a routable and discoverable 
        // service on the network. Nomad automatically registers when a task is started and de-registers it when the task 
        // transitons to the dead state.
        service {

            // Nomad automatically determines the name of a Task. By default the name of a service is 
            // $(job-name)-$(task-group)-$(task-name). Users can explicitly name the service by specifying this option. If 
            // multiple services are defined for a Task then only one task can have the default name, all the services have to be 
            // explicitly named. Users can add the following to the service names: ${JOB}, ${TASKGROUP}, ${TASK}, ${BASE}. Nomad 
            // will replace them with the appropriate value of the Job, Task Group and Task names while registering the Job. ${BASE} 
            // expands to ${JOB}-${TASKGROUP}-${TASK}.
            name = "${JOB}-nginx"

            // A list of tags associated with this Service.
            tags = ["experiment", "proxy"]

            // The port indicates the port associated with the Service. Users are required to specify a valid port label here 
            // which they have defined in the resources block. This could be a label to either a dynamic or a static port. If an 
            // incorrect port label is specified, Nomad doesn't register the service with Consul.
            port = "insecure"

            // A check block defines a health check associated with the service. Multiple check blocks are allowed for a service. 
            // Nomad currently supports only the http and tcp Consul Checks.
            check {
                // This indicates the check types supported by Nomad. Valid options are currently http and tcp. In the future 
                // Nomad will add support for more Consul checks.
                type = "tcp"

                // This indicates the frequency of the health checks that Consul with perform.
                delay = "30s"

                // This indicates how long Consul will wait for a health check query to succeed.
                timeout = "2s"

                // The path of the http endpoint which Consul will query to query the health of a service if the type of the check 
                // is http. Nomad will add the ip of the service and the port, users are only required to add the relative url of 
                // the health check endpoint.
                path = "/"

                // This indicates the protocol for the http checks. Valid options are http and https. We default it to http.
                protocol = "http"
            }
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
#           iops = 10

            // The memory required in MB.
            memory = 512

            // The network required.  
            network {
                // The number of MBits in bandwidth required.
                mbits = 100
                port "insecure" {
#                   static = 80
                }
                port "secure" {
#                   static = 443
                }
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