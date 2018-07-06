
<cfscript>
    if (!isDefined('redirect')) {
        id = m.event('id');
        if (!isValid('uuid', id))
            id = CreateUUID();
        redirect = m.getBean('redirect').loadBy(redirectId=id);
    } else {
        id = redirect.get('redirectId');
    }
    if (redirect.getIsNew()) {
        label = 'Add';
    } else {
        label = 'Save';
    }
</cfscript>

<cfsavecontent variable="topButtons"><cfoutput>
    <cfif !redirect.getIsNew()>
        <cfset token = m.renderCSRFTokens(format='url',context='reset_redirect')>
        <a class="btn" title="Reset Hit Count" href="./?action=reset_redirect&amp;id=#id#&amp;next_action=edit_redirect#token#">
            <i class="mi-undo"></i> Reset Hit Count
        </a>
    </cfif>
    <a class="btn" title="Back to Redirect List" href="./?action=redirect_list">
        <i class="mi-arrow-circle-left"></i> Back to Redirect List
    </a>
</cfoutput></cfsavecontent>

<cfsavecontent variable="body"><cfoutput>
    <form name="editRedirect" method="post" action=".?action=save_redirect">
        <div class="mura-control-group">
            <label for="sourceProtocolValue">Source Protocol</label>
            <cfset protocol = redirect.get('sourceProtocolValue')>
            <select id="sourceProtocolValue" name="sourceProtocolValue" autofocus>
                <option value=""#protocol  eq '' ? ' selected' : ''#>Any</option>
                <option value="https"#protocol  eq 'https' ? ' selected' : ''#>https</option>
                <option value="http"#protocol  eq 'http' ? ' selected' : ''#>http</option>
            </select>
        </div>
        <div class="mura-control-group">
            <label for="sourceDomainValue">Source Domain</label>
            <input id="sourceDomainValue" name="sourceDomainValue" type="text"
                value="#encodeForHTMLAttribute(redirect.get('sourceDomainValue'))#">
            <label><input type="checkbox" name="sourceDomainRegexp" value="true"#redirect.get('sourceDomainRegexp') ? ' checked' : ''#> Regular expression</label>
        </div>
        <div class="mura-control-group">
            <label for="sourcePathValue">Source Path (should end with a /)</label>
            <input id="sourcePathValue" name="sourcePathValue" type="text"
                value="#encodeForHTMLAttribute(redirect.get('sourcePathValue'))#">
            <label><input type="checkbox" name="sourcePathRegexp" value="true"#redirect.get('sourcePathRegexp') ? ' checked' : ''#> Regular expression</label>
        </div>
        <div class="mura-control-group">
            <label for="targetURL">Target URL</label>
            <input id="targetURL" name="targetURL" type="text"
                value="#encodeForHTMLAttribute(redirect.get('targetURL'))#">
        </div>
        <div class="mura-control-group">
            <label for="statusCode">Status Code</label>
            <cfset statusCode = redirect.get('statusCode')>
            <select id="statusCode" name="statusCode">
            <!--- apparently ColdFusion does not support 308 --->
                <option value="301"#statusCode eq 301 ? ' selected' : ''#>301 (permanent redirect)</option>
                <option value="302"#statusCode eq 302 ? ' selected' : ''#>302 (temporary redirect)</option>
            </select>
        </div>
        <div class="mura-control-group">
            <label><input type="checkbox" name="enabled" value="true"#redirect.get('enabled') ? ' checked' : ''#> Enabled</label>
        </div>
        <div class="mura-control-group">
            <label for="notes">Notes</label>
            <textarea id="notes" name="notes" rows="4" cols="80">#encodeForHTMLAttribute(redirect.get('notes'))#</textarea>
        </div>
        <cfif !redirect.getIsNew()>
            <p>Hit count: #redirect.get('hitCount')#</p>
            <cfif redirect.get('lastHit') neq ''>
                <p>Last hit: #dateTimeFormat(redirect.get('lastHit'), 'short')#</p>
            </cfif>
            <p>Count start: #dateTimeFormat(redirect.get('countStart'), 'short')#</p>
            <cfif redirect.get('createdOn') neq ''>
                <p>Created on: #dateTimeFormat(redirect.get('createdOn'), 'short')#</p>
            </cfif>
            <cfif redirect.get('updatedOn') neq ''>
                <p>Updated on: #dateTimeFormat(redirect.get('updatedOn'), 'short')#</p>
            </cfif>
            <cfif redirect.get('updatedBy') neq ''>
                <p style="padding-bottom:30px">Updated by: #redirect.get('updatedBy')#</p>
            </cfif>
        </cfif>

        <input type="hidden" name="siteID" value="#m.siteConfig('siteID')#">

        <input type="hidden" name="id" value="#id#">
        #m.renderCSRFTokens(format='form', context='edit_redirect')#

        <div class="mura-actions">
            <div class="form-actions">
                <cfif !redirect.getIsNew()>
                    <cfset token = m.renderCSRFTokens(format='url', context='delete_redirect')>
                    <cfset deleteUrl = "./?action=delete_redirect&amp;id=#redirect.get('redirectId')##token#">
                    <button class="btn" type="button"
                        onclick="confirmDialog('Delete #redirect.getFullName()# ?', function() {
                            actionModal('#deleteUrl#')
                            }); return false;">
                        <i class="mi-trash"></i>Delete
                    </button>
                </cfif>
                <button type="submit" class="btn mura-primary">
                    <i class="mi-check-circle"></i>#label#
                </button>
            </div>
        </div>
    </form>
</cfoutput></cfsavecontent>

<cfinclude template="layout.cfm">
