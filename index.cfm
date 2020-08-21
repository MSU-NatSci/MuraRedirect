<!--- Main plugin page. All requests are being handled here. --->

<cfscript>
    include 'plugin/config.cfm';

    import MuraRedirect.model.Redirects;

    m = $;
    action(pluginConfig);

    function action(pluginConfig) {
        var action = m.event('action');
        var result = {};

        var result = {};
        if (action == 'save_redirect' || action == 'delete_redirect' ||
                action == 'reset_redirect' || action == 'disable_redirect' ||
                action == 'enable_redirect') {
            var redirectMgt = new MuraRedirect.model.RedirectMgt(m);
            result = redirectMgt.handleAction(action);
        }
        if (structKeyExists(result, 'action'))
            action = result.action;
        if (structKeyExists(result, 'redirect'))
            redirect = result.redirect;
        if (structKeyExists(result, 'message'))
            message = result.message;

        if (action == 'edit_redirect')
            include 'views/edit_redirect.cfm';
        else
            include 'views/redirect_list.cfm';
    }
</cfscript>
