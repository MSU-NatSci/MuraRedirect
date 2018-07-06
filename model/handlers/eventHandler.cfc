component accessors=true extends='mura.plugin.pluginGenericEventHandler' output=false {

    include '../../plugin/settings.cfm';

    public any function onApplicationLoad(required struct m) {
        arguments.m.globalConfig().registerBeanDir("/#settings.package#/model/beans/");
        // Register all event handlers/listeners of this .cfc with Mura CMS
        variables.pluginConfig.addEventHandler(this);
    }

    public any function onSiteRequestStart(m) {
        /*
		NOTE: we are using REQUEST.currentFilename instead of URL.path which is
		not reliable in Mura 7.1, see
	    https://github.com/blueriver/MuraCMS/issues/2859
        */
	    var filePath = (REQUEST.currentFilename eq '' ? '/' :
            '/' & REQUEST.currentFilename & '/');
        var domain = CGI.SERVER_NAME;
        var protocol = (CGI.SERVER_PROTOCOL.findNoCase('https') == 1 ? 'https' : 'http');
	    var siteID = $.siteConfig('siteID');
        var redirectMgt = new MuraRedirect.model.RedirectMgt(m);
        var res = redirectMgt.getRedirectURL(siteID, protocol, domain, filePath);
        if (res.found) {
            var redirect = res.redirect;
            var redirectURL = res.url;
            redirect.setHitCount(redirect.getHitCount() + 1);
            redirect.setLastHit(now());
            redirect.save();
            location(redirectURL, false, redirect.getStatusCode());
        }
    }
}
