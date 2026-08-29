resource "azurerm_application_insights_workbook" "reo_runs" {
  name                = "e15341a9-bb4e-475d-9eb3-bf1b90d86d71"
  resource_group_name = data.azurerm_resource_group.reo.name
  location            = var.location
  display_name        = "REO Run Operations"
  description         = "REO runs, heartbeats, long-running workloads, and execution logs."
  category            = "workbook"
  source_id           = lower(azurerm_log_analytics_workspace.reo.id)

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text - title"
        content = {
          json = "# REO Run Operations\n\nExecution state, heartbeats, long-running workload detection, and raw REO logs. Long-running means a running or pending pod older than 45 seconds; REO has a 60-second execution cap."
        }
      },
      {
        type = 9
        name = "parameters - time range"
        content = {
          version = "KqlParameterItem/1.0"
          parameters = [
            {
              id         = "a0cb4b5c-b9ae-4ae7-b96d-5d1d4fe2820e"
              name       = "TimeRange"
              label      = "Time range"
              type       = 4
              value      = { durationMs = 86400000 }
              isRequired = true
              typeSettings = {
                selectAllValue            = "All"
                additionalResourceOptions = []
              }
            }
          ]
        }
      },
      {
        type = 3
        name = "query - recent runs"
        content = {
          version       = "KqlItem/1.0"
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          resourceIds   = [lower(azurerm_log_analytics_workspace.reo.id)]
          visualization = "table"
          size          = 0
          timeContext   = { durationMs = 86400000 }
          query         = <<-KQL
            KubePodInventory
            | where TimeGenerated {TimeRange}
            | where Namespace == "reo-runs"
            | summarize arg_max(TimeGenerated, *) by Name
            | extend Runtime = now() - todatetime(PodStartTime)
            | project LastSeen=TimeGenerated, Pod=Name, Workflow=ControllerName, Phase=PodStatus, ContainerStatus, Started=todatetime(PodStartTime), Runtime
            | order by LastSeen desc
          KQL
        }
      },
      {
        type = 3
        name = "query - heartbeat"
        content = {
          version       = "KqlItem/1.0"
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          resourceIds   = [lower(azurerm_log_analytics_workspace.reo.id)]
          visualization = "table"
          size          = 0
          timeContext   = { durationMs = 86400000 }
          query         = <<-KQL
            ContainerLogV2
            | where TimeGenerated {TimeRange}
            | where PodNamespace == "reo-runs"
            | where tostring(LogMessage) has "REO_HEARTBEAT"
            | project TimeGenerated, PodName, ContainerName, LogMessage
            | order by TimeGenerated desc
          KQL
        }
      },
      {
        type = 3
        name = "query - long running"
        content = {
          version       = "KqlItem/1.0"
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          resourceIds   = [lower(azurerm_log_analytics_workspace.reo.id)]
          visualization = "table"
          size          = 0
          timeContext   = { durationMs = 86400000 }
          query         = <<-KQL
            KubePodInventory
            | where TimeGenerated {TimeRange}
            | where Namespace == "reo-runs"
            | summarize arg_max(TimeGenerated, *) by Name
            | where PodStatus in~ ("Running", "Pending")
            | extend Runtime = now() - todatetime(PodStartTime)
            | where Runtime > 45s
            | project Pod=Name, Workflow=ControllerName, Phase=PodStatus, ContainerStatus, Started=todatetime(PodStartTime), Runtime, LastSeen=TimeGenerated
            | order by Runtime desc
          KQL
        }
      },
      {
        type = 3
        name = "query - execution logs"
        content = {
          version       = "KqlItem/1.0"
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          resourceIds   = [lower(azurerm_log_analytics_workspace.reo.id)]
          visualization = "table"
          size          = 0
          timeContext   = { durationMs = 86400000 }
          query         = <<-KQL
            ContainerLogV2
            | where TimeGenerated {TimeRange}
            | where PodNamespace == "reo-runs"
            | where PodName startswith "reo-"
            | project TimeGenerated, PodName, ContainerName, LogMessage, LogSource
            | order by TimeGenerated desc
          KQL
        }
      }
    ]
    isLocked            = false
    fallbackResourceIds = [lower(azurerm_log_analytics_workspace.reo.id)]
  })
}
