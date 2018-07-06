<!--- This template handles the layout for all pages in the plugin --->
<cfinclude template="../plugin/settings.cfm">

<cfparam name="message" type="struct" default="#{}#"> <!--- keys: type (error|warning|success|info), content (can contain HTML) --->
<cfparam name="topButtons" type="string" default=""> <!--- contains HTML --->
<cfparam name="body" type="string" default=""> <!--- contains HTML --->

<cfsavecontent variable="pageBody"><cfoutput>
    <cfif IsDefined('message.type')>
        <div class="alert alert-#message.type#" role="alert">
            <div>
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <strong>#message.content#</strong>
            </div>
        </div>
    </cfif>
    <div class="mura-header">
        <h1>#HTMLEditFormat(pluginConfig.getName())#</h1>
        <cfif topButtons neq ''>
            <div class="nav-module-specific btn-group">
                #topButtons#
            </div>
        </cfif>
    </div>
    <div class="block block-bordered">
        <div class="block-content">
            #body#
        </div>
    </div>
</cfoutput></cfsavecontent>

<cfsavecontent variable="output"><cfoutput>
    #m.getBean('pluginManager').renderAdminTemplate(body=pageBody, pageTitle=pluginConfig.getName())#    
</cfoutput></cfsavecontent>
<!--- Insert the CSS link in the output (Mura does not provide any clean way to do that --->
<cfset pluginspath = m.siteConfig().getPluginsPath()>
<cfset cssPath = pluginspath & '/#settings.package#/assets/css/mura_redirect.css'>
<cfset cssLink = '<link href="#cssPath#" rel="stylesheet" type="text/css" />'>
<cfset pos = Find('<link href', output) - 1>
<cfset output = Insert(cssLink, output, pos)>
<cfoutput>
#output#
</cfoutput>
