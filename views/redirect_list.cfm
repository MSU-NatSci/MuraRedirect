<cfif getBaseTemplatePath() eq getCurrentTemplatePath()>
    Direct execution denied.
    <cfabort>
</cfif>

<!--- check the table exists first --->
<cfset dbUtility = m.getBean('dbUtility')>
<cfset redirectTable = m.getBean('redirect').getTable()>
<cfif !dbUtility.tableExists(redirectTable)>
    <cfsavecontent variable="body"><cfoutput>
        <p>The redirect table has not been created yet.</p>
        <cfset configBean = m.getBean('configBean')>
        <cfset appreloadkey = configBean.get('appreloadkey')>
        <a class="btn" title="Reload Mura and apply database updates" href="?#appreloadkey#&amp;applydbupdates">
            <i class="mi-refresh"></i> Reload Mura and apply database updates
        </a>
    </cfoutput></cfsavecontent>
<cfelse>
<!--- display the list of redirects --->
<cfset redirectMgt = new MuraRedirect.model.RedirectMgt(m)>

<cfsavecontent variable="topButtons"><cfoutput>
    <a class="btn" title="Add Redirect" href="./?action=edit_redirect">
        <i class="mi-plus-circle"></i> Add Redirect
    </a>
    <cfset pluginConfig = m.getPlugin(settings.pluginName)>
    <cfset moduleid = pluginConfig.getValue('moduleid')>
    <a class="btn" title="Plugin Permissions" href="#m.globalConfig('context')#/admin/?muraAction=cPerm.module&amp;contentid=#moduleid#&amp;siteid=#session.siteid#&amp;moduleid=#moduleid#">
        <i class="mi-key"></i> Plugin Permissions
    </a>
</cfoutput></cfsavecontent>

<cfsavecontent variable="body"><cfoutput>
    <table class="mura-table-grid">
        <thead>
            <tr>
                <th class="actions"></th>
                <th class="var-width">Domain</th>
                <th class="var-width">Path</th>
                <th class="var-width">Target URL</th>
                <th>Code</th>
                <th>Hit count</th>
                <!--- it would be nice to use bootstrap 4 classes here, but Mura
                    defines the display classes in its own CSS, based on bootstrap 3 --->
                <th class="hidden-xs hidden-sm hidden-md">Last hit</th>
                <th>Enabled</th>
                <th class="var-width hidden-xs hidden-sm hidden-md hidden-lg">Notes</th>
            </tr>
        </thead>
        <tbody>
            <cfset redirects = redirectMgt.getIterator()>
            <cfloop condition="redirects.hasNext()">
                <cfset redirect = redirects.next()>
                <cfset id = redirect.get('redirectId')>
                <cfset domain = redirect.get('sourceDomainValue')>
                <cfset path = redirect.get('sourcePathValue')>
                <cfset targetURL = redirect.get('targetURL')>
                <cfset statusCode = redirect.get('statusCode')>
                <cfset hitCount = redirect.get('hitCount')>
                <cfset lastHit = redirect.get('lastHit')>
                <cfset enabled = redirect.get('enabled')>
                <cfset notes = redirect.get('notes')>
                <cfset editURL = "./?action=edit_redirect&amp;id=#id#">
                <tr>
                    <td class="actions">
                        <a class="show-actions" href="javascript:;" ontouchstart="this.onclick();" onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
                        <div class="actions-menu hide">
                            <ul class="actions-list">
                                <li class="edit">
                                    <a href="#editURL#">
                                        <i class="mi-pencil"></i>Edit
                                    </a>
                                </li>
                                <li>
                                    <cfset token = m.renderCSRFTokens(format='url',context='reset_redirect')>
                                    <a href="./?action=reset_redirect&amp;id=#id##token#">
                                        <i class="mi-undo"></i>Reset hit count
                                    </a>
                                </li>
                                <li>
                                    <cfif redirect.getEnabled()>
                                        <cfset token = m.renderCSRFTokens(format='url',context='set_redirect_enabled')>
                                        <a href="./?action=disable_redirect&amp;id=#id##token#">
                                            <i class="mi-ban"></i>Disable
                                        </a>
                                    <cfelse>
                                        <cfset token = m.renderCSRFTokens(format='url',context='set_redirect_enabled')>
                                        <a href="./?action=enable_redirect&amp;id=#id##token#">
                                            <i class="mi-check"></i>Enable
                                        </a>
                                    </cfif>
                                </li>
                                <li class="delete">
                                    <cfset token = m.renderCSRFTokens(format='url',context='delete_redirect')>
                                    <cfset deleteUrl = "./?action=delete_redirect&amp;id=#id##token#">
                                    <a href="##" onclick="confirmDialog('Delete #encodeForJavaScript(domain)# #encodeForJavaScript(path)# redirect ?', function() { actionModal('#deleteUrl#') }); return false;">
                                        <i class="mi-trash"></i>Delete
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </td>
                    <td class="var-width"><a href="#editURL#" title="#encodeForHTMLAttribute(domain)#">#encodeForHTML(domain)#</a></td>
                    <td class="var-width"><a href="#editURL#" title="#encodeForHTMLAttribute(path)#">#encodeForHTML(path)#</a></td>
                    <td class="var-width"><a href="#editURL#" title="#encodeForHTMLAttribute(targetURL)#">#encodeForHTML(targetURL)#</a></td>
                    <td>#statusCode#</td>
                    <td>#hitCount#</td>
                    <td class="hidden-xs hidden-sm hidden-md">#dateTimeFormat(lastHit, 'short')#</td>
                    <td><cfif enabled>
                        <i class="mi-check" title="Yes"></i>
                    <cfelse>
                        <i class="mi-ban" title="No"></i>
                    </cfif></td>
                    <td class="var-width hidden-xs hidden-sm hidden-md hidden-lg" title="#encodeForHTMLAttribute(notes)#">#encodeForHTML(notes)#</td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</cfoutput></cfsavecontent>

</cfif>

<cfinclude template="layout.cfm">
