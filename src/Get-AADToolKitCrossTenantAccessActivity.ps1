<#
.SYNOPSIS
    Gets cross tenant user sign-in activity

.DESCRIPTION
    Gets user sign-in activity associated with external tenants. By default, shows both connections
    from local users access an external tenant (outbound), and external users accessing the local
    tenant (inbound). 
    
    Has a parameter, -AccessDirection, to further refine results, using the following values: 

        * Outboud - lists sign-in events of external tenant IDs accessed by local users
        * Inbound - list sign-in events of external tenant IDs of external users accessing local tenant

    Has a parameter, -ExternalTenantId, to target a single external tenant ID.

    Has a switch, -SummaryStats, to show summary statistics for each external tenant. This also works 
    when targeting a single tenant. It is best to use this with Format-Table and Out-Gridview to ensure 
    a table is produced.

    -Verbose will give insight into the cmdlets activities.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity

    Gets all available sign-in events for external users accessing resources in the local tenant and
    local users accessing resources in an external tenant.

    Lists by targeted external tenant.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -Verbose

    Gets all available sign-in events for external users accessing resources in the local tenant and
    local users accessing resources in an external tenant.

    Lists by targeted external tenant.

    Provides verbose output for insight into the cmdlet's execution.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -SummaryStats | Format-Table

    Provides a summary for sign-in information for the external tenant 3ce14667-9122-45f5-bcd4-f618957d9ba1, for both external
    users accessing resources in the local tenant and local users accessing resources in an external tenant.

    Use Format-Table to ensure a table is returned.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -ExternalTenantId 3ce14667-9122-45f5-bcd4-f618957d9ba1

    Gets all available sign-in events for local users accessing resources in the external tenant 3ce14667-9122-45f5-bcd4-f618957d9ba1, 
    and external users from tenant 3ce14667-9122-45f5-bcd4-f618957d9ba1 accessing resources in the local tenant.

    Lists by targeted external tenant.

    
.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Outbound

    Gets all available sign-in events for local users accessing resources in an external tenant. 

    Lists by unique external tenant.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Outbound -Verbose

    Gets all available sign-in events for local users accessing resources in an external tenant. 

    Lists by unique external tenant.

    Provides verbose output for insight into the cmdlet's execution.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Outbound -SummaryStats | Format-Table

    Provides a summary of sign-ins for local users accessing resources in an external tenant.

    Use Format-Table to ensure a table is returned.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Outbound -ExternalTenantId 3ce14667-9122-45f5-bcd4-f618957d9ba1

    Gets all available sign-in events for local users accessing resources in the external tenant 3ce14667-9122-45f5-bcd4-f618957d9ba1.

    Lists by unique external tenant.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Inbound

    Gets all available sign-in events for external users accessing resources in the local tenant. 

    Lists by unique external tenant.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Inbound -Verbose

    Gets all available sign-in events for external users accessing resources in the local tenant. 

    Lists by unique external tenant.

    Provides verbose output for insight into the cmdlet's execution.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Inbound -SummaryStats | Out-Gridview

    Provides a summary of sign-ins for external users accessing resources in the local tenant.

    Use Out-Gridview to display a table in the Out-Gridview window.


.EXAMPLE
    Get-AADToolKitCrossTenantAccessActivity -AccessDirection Inbound -ExternalTenantId 3ce14667-9122-45f5-bcd4-f618957d9ba1

    Gets all available sign-in events for external user from external tenant 3ce14667-9122-45f5-bcd4-f618957d9ba1 accessing
    resources in the local tenant.

    Lists by unique external tenant.


.NOTES
    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 
    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
    implied warranties including, without limitation, any implied warranties of merchantability
    or of fitness for a particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall Microsoft, its authors,
    or anyone else involved in the creation, production, or delivery of the script be liable for 
    any damages whatsoever (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary loss) arising out of 
    the use of or inability to use the sample or documentation, even if Microsoft has been advised 
    of the possibility of such damages, rising out of the use of or inability to use the sample script, 
    even if Microsoft has been advised of the possibility of such damages.   


#>
function Get-AADToolKitCrossTenantAccessActivity {

    [CmdletBinding()]
    param(

        #Return events based on external tenant access direction, either 'Inbound', 'Outbound', or 'Both'
        [Parameter(Position=0)]
        [ValidateSet('Inbound','Outbound')] 
        [string]$AccessDirection,

        #Return events for the supplied external tenant ID
        [Parameter(Position=1)]
        [guid]$ExternalTenantId,

        #Show summary statistics by tenant
        [switch]$SummaryStats

        )
    
    begin {
        
        #Connection and profile check

        Write-Verbose -Message "$(Get-Date -f T) - Checking connection..."

        if ($null -eq (Get-MgContext)) {

            Write-Error "$(Get-Date -f T) - Please connect to MS Graph API with the Connect-AADToolkit cmdlet!" -ErrorAction Stop
        }
        else {

            Write-Verbose -Message "$(Get-Date -f T) - Checking profile..."

            if ((Get-MgProfile).Name -eq 'v1.0') {

                Write-Error "$(Get-Date -f T) - Current MGProfile is set to v1.0, and some cmdlets may need to use the beta profile. Run 'Select-MgProfile -Name beta' to switch to beta API profile" -ErrorAction Stop
            }

        }

        Write-Verbose -Message "$(Get-Date -f T) - Connection and profile OK"


        #External Tenant ID check

        if ($ExternalTenantId) {

            Write-Verbose -Message "$(Get-Date -f T) - Checking supplied external tenant ID - $ExternalTenantId..."

            if ($ExternalTenantId -eq (Get-MgContext).TenantId) {

                Write-Error "$(Get-Date -f T) - Supplied external tenant ID ($ExternalTenantId) cannot match connected tenant ID ($((Get-MgContext).TenantId)))" -ErrorAction Stop

            }
            else {

                Write-Verbose -Message "$(Get-Date -f T) - Supplied external tenant ID OK"
            }

        }

    }
    
    process {

        #Get filtered sign-in logs and handle parameters

        if ($AccessDirection -eq "Outbound") {

            if ($ExternalTenantId) {

                Write-Verbose -Message "$(Get-Date -f T) - Access direction 'Outbound' selected"
                Write-Verbose -Message "$(Get-Date -f T) - Outbound: getting sign-ins for local users accessing external tenant ID - $ExternalTenantId"
            
                $SignIns = Get-MgAuditLogSignIn -Filter ("ResourceTenantId eq '{0}'" -f $ExternalTenantId) -all:$True | Group-Object ResourceTenantID

            }
            else {

                Write-Verbose -Message "$(Get-Date -f T) - Access direction 'Outbound' selected"
                Write-Verbose -Message "$(Get-Date -f T) - Outbound: getting external tenant IDs accessed by local users"

                $SignIns = Get-MgAuditLogSignIn -Filter ("ResourceTenantId ne '{0}'" -f (Get-MgContext).TenantId) -all:$True | Group-Object ResourceTenantID
            }

        }
        elseif ($AccessDirection -eq 'Inbound') {

            if ($ExternalTenantId) {

                Write-Verbose -Message "$(Get-Date -f T) - Access direction 'Inbound' selected"
                Write-Verbose -Message "$(Get-Date -f T) - Inbound: getting sign-ins for users accessing local tenant from external tenant ID - $ExternalTenantId"

                $SignIns = Get-MgAuditLogSignIn -Filter ("HomeTenantId eq '{0}' and TokenIssuerType eq 'AzureAD'" -f $ExternalTenantId) -all:$True | Group-Object HomeTenantID

            }
            else {

                Write-Verbose -Message "$(Get-Date -f T) - Access direction 'Inbound' selected"
                Write-Verbose -Message "$(Get-Date -f T) - Inbound: getting external tenant IDs for external users accessing local tenant"

                $SignIns = Get-MgAuditLogSignIn -Filter ("HomeTenantId ne '{0}' and TokenIssuerType eq 'AzureAD'" -f (Get-MgContext).TenantId) -all:$True | Group-Object HomeTenantID

            }

        }
        else {

            if ($ExternalTenantId) {

                Write-Verbose -Message "$(Get-Date -f T) - Default access direction 'Both'"
                Write-Verbose -Message "$(Get-Date -f T) - Outbound: getting sign-ins for local users accessing external tenant ID - $ExternalTenantId"
            
                $Outbound = Get-MgAuditLogSignIn -Filter ("ResourceTenantId eq '{0}'" -f $ExternalTenantId) -all:$True | Group-Object ResourceTenantID


                Write-Verbose -Message "$(Get-Date -f T) - Inbound: getting sign-ins for users accessing local tenant from external tenant ID - $ExternalTenantId"

                $Inbound = Get-MgAuditLogSignIn -Filter ("HomeTenantId eq '{0}' and TokenIssuerType eq 'AzureAD'" -f $ExternalTenantId) -all:$True | Group-Object HomeTenantID


            }
            else {

                Write-Verbose -Message "$(Get-Date -f T) - Default access direction 'Both'"
                Write-Verbose -Message "$(Get-Date -f T) - Outbound: getting external tenant IDs accessed by local users"

                $Outbound = Get-MgAuditLogSignIn -Filter ("ResourceTenantId ne '{0}'" -f (Get-MgContext).TenantId) -all:$True | Group-Object ResourceTenantID


                Write-Verbose -Message "$(Get-Date -f T) - Inbound: getting external tenant IDs for external users accessing local tenant"

                $Inbound = Get-MgAuditLogSignIn -Filter ("HomeTenantId ne '{0}' and TokenIssuerType eq 'AzureAD'" -f (Get-MgContext).TenantId) -all:$True | Group-Object HomeTenantID



            }

                #Combine outbound and inbound results

                [array]$SignIns = $Outbound
                $SignIns += $Inbound



        }


        #Analyse sign-in logs

        Write-Verbose -Message "$(Get-Date -f T) - Checking for sign-ins..."

        if ($SignIns) {
            
            Write-Verbose -Message "$(Get-Date -f T) - Sign-ins obtained"
            Write-Verbose -Message "$(Get-Date -f T) - Iterating Sign-ins..."

            foreach ($TenantID in $SignIns) {

                #Provide summary

                if ($SummaryStats) {

                    Write-Verbose -Message "$(Get-Date -f T) - Creating summary stats for external tenant - $($TenantId.Name)"

                    if (($AccessDirection -eq 'Inbound') -or ($AccessDirection -eq 'Outbound')) {

                        $Direction = $AccessDirection

                    }
                    else {

                        if ($TenantID.Name -eq $TenantID.Group[0].HomeTenantId) {

                            $Direction = "Inbound"

                        }
                        elseif ($TenantID.Name -eq $TenantID.Group[0].ResourceTenantId) {

                            $Direction = "Outbound"

                        }

                    }

                    #Build custom output object

                    $Analysis = [pscustomobject]@{

                        ExternalTenantId = $TenantId.Name
                        AccessDirection = $Direction
                        SignIns = $TenantId.Count
                        SuccessSignIns = ($TenantID.Group.Status | Where-Object {$_.ErrorCode -eq 0}).count
                        FailedSignIns = ($TenantID.Group.Status | Where-Object {$_.ErrorCode -ne 0}).count
                        UniqueUsers = ($TenantID.Group | Select-Object UserId -unique).count
                        UniqueResources = ($TenantID.Group | Select-Object ResourceId -unique).count


                    }

                    Write-Verbose -Message "$(Get-Date -f T) - Adding stats for $($TenantId.Name) to total analysis object"

                    [array]$TotalAnalysis += $Analysis

                }
                else {

                    #Get individual events by external tenant

                    Write-Verbose -Message "$(Get-Date -f T) - Getting individual sign-in events for external tenant - $($TenantId.Name)"

                    $TenantID.group | Select-Object @{n='ExternalTenantId';e={$TenantId.name}},UserDisplayName,UserPrincipalName,UserId,UserType,CrossTenantAccessType,AppDisplayName,AppId,`
                                                    ResourceDisplayName,ResourceId,@{n='SignInId';e={$_.Id}},CreatedDateTime,@{n='StatusCode';e={$_.Status.ErrorCode}}, `
                                                    @{n='Statusreason';e={$_.Status.FailureReason}}

                }

            }

        }
        else {

            Write-Warning "$(Get-Date -f T) - No sign-ins matching the selected criteria found."

        }

        #Display summary table

        if ($SummaryStats) {

            #Show array of summary objects for each external tenant

            Write-Verbose -Message "$(Get-Date -f T) - Displaying total analysis object"

            if (!$AccessDirection) {
            
                $TotalAnalysis | Sort-Object ExternalTenantId 
            
            }
            else {
           
                $TotalAnalysis | Sort-Object SignIns -Descending 

            }

        }


    }
       
}