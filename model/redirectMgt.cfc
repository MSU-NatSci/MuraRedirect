/**
 * Redirect management (iterator, save, delete, ...).
 */
component {

    public function init(m) {
        variables.m = m;
    }

    /**
     * Returns an iterator with all redirect beans.
     */
    public mura.bean.beanIterator function getIterator() {
         return m.getFeed('redirect').getIterator();
    }

    /**
     * Handles the UI action and returns a corresponding struct.
     */
    public struct function handleAction(required string action) {
        if (action == 'delete_redirect')
            return this.deleteRedirect(m.event('id'));
        else if (action == 'save_redirect')
            return this.saveRedirect();
        else if (action == 'reset_redirect')
            return this.resetRedirect(m.event('id'), m.event('next_action'));
        else if (action == 'disable_redirect')
            return this.setRedirectEnabled(m.event('id'), false);
        else if (action == 'enable_redirect')
            return this.setRedirectEnabled(m.event('id'), true);
    }

    /**
     * Deletes a redirect record.
     * Returns a struct with:
     *   - action: the name of the view to use next
     *   - message: a message to display (type/content)
     * Requires a CSRF token with the 'delete_redirect' context.
     */
    public struct function deleteRedirect(required string id) {
        var result = {};
        var message = {};
        if (m.validateCSRFTokens(context='delete_redirect')) {
            try {
                var redirect = m.getBean('redirect').loadBy(redirectId=id);
                redirect.delete();
                message = {
                    type = 'success',
                    content = "Deleted redirect."
                };
            } catch (any e) {
                message = {
                    type = 'error',
                    content = e.message
                };
            }
        } else {
            message = {
                type = 'error',
                content = "Unable to delete due to invalid CSRF token."
            };
        }
        result.action = 'redirect_list';
        result.message = message;
        return result;
    }

    /**
     * Create a new or updates a redirect record.
     * Uses the form variable to get field values.
     * Returns a struct with:
     *   - action: the name of the view to use next
     *   - redirect: the new redirect bean
     *   - message: a message to display (type/content)
     * Requires a CSRF token with the 'edit_redirect' context.
     */
    public struct function saveRedirect() {
        var result = {};
        var action = 'redirect_list';
        var message = {};
        var id = '';
        if (structKeyExists(form, 'id'))
            id = form.id;
        if (!isValid('uuid', id))
            id = createUUID();
        var redirect = m.getBean('redirect').loadBy(redirectId=m.event('id'));
        var newRedirect = redirect.getIsNew();
        if (m.validateCSRFTokens(context='edit_redirect')) {
            if (form.sourceDomainValue eq '' and form.sourcePathValue eq '') {
                message = {
                    type = 'error',
                    content = "The domain and path values cannot be both empty."
                };
                action = 'edit_redirect';
            } else {
                try {
                    redirect.set('siteID', form.siteID);
                    redirect.set('sourceProtocolValue', form.sourceProtocolValue);
                    redirect.set('sourceDomainValue', form.sourceDomainValue);
                    redirect.set('sourceDomainRegexp',
                        structKeyExists(form, 'sourceDomainRegexp') and
                        form.sourceDomainRegexp eq 'true');
                    redirect.set('sourcePathValue', form.sourcePathValue);
                    redirect.set('sourcePathRegexp',
                        structKeyExists(form, 'sourcePathRegexp') and
                        form.sourcePathRegexp eq 'true');
                    redirect.set('targetURL', form.targetURL);
                    redirect.set('statusCode', form.statusCode);
                    redirect.set('enabled',
                        structKeyExists(form, 'enabled') and
                        form.enabled eq 'true');
                    redirect.set('notes', form.notes);
                    if (newRedirect) {
                        redirect.set('countStart', now());
                        redirect.set('createdOn', now());
                    } else {
                        redirect.set('updatedOn', now());
                    }
                    redirect.set('updatedBy', m.currentUser('username'));
                    
                    var result = redirect.save();

                    var errors = result.get('errors');
                    if (isDefined('errors') && structCount(errors)) {
                        action = 'edit_redirect';
                        var messageContent = '<ul>';
                        for (var errorKey in errors)
                            messageContent &= '<li>#errors[errorKey]#</li>';
                        messageContent &= '</ul>';
                        message = {
                            type = 'error',
                            content = messageContent
                        };
                    } else {
                        message = {
                            type = 'success',
                            content = (newRedirect ? "Added " : "Updated ") &
                                "redirect."
                        };
                    }
                } catch (any e) {
                    message = {
                        type = 'error',
                        content = e.message
                    };
                    action = 'edit_redirect';
                }
            }
        } else {
            message = {
                type = 'error',
                content = "Unable to save due to invalid CSRF token."
            };
            action = 'edit_redirect';
        }
        result.action = action;
        result.redirect = redirect;
        result.message = message;
        return result;
    }

    public struct function resetRedirect(required string id, string next_action) {
        var result = {};
        var message = {};
        if (m.validateCSRFTokens(context='reset_redirect')) {
            try {
                var redirect = m.getBean('redirect').loadBy(redirectId=id);
                redirect.setHitCount(0);
                redirect.setCountStart(now());
                redirect.setLastHit('');
                var result = redirect.save();

                var errors = result.get('errors');
                if (isDefined('errors') && structCount(errors)) {
                    action = 'edit_redirect';
                    var messageContent = '<ul>';
                    for (var errorKey in errors)
                        messageContent &= '<li>#errors[errorKey]#</li>';
                    messageContent &= '</ul>';
                    message = {
                        type = 'error',
                        content = messageContent
                    };
                } else {
                    message = {
                        type = 'success',
                        content = "Reset redirect."
                    };
                }
            } catch (any e) {
                message = {
                    type = 'error',
                    content = e.message
                };
            }
        } else {
            message = {
                type = 'error',
                content = "Unable to delete due to invalid CSRF token."
            };
        }
        if (next_action == 'edit_redirect')
            result.action = 'edit_redirect';
        else
            result.action = 'redirect_list';
        result.message = message;
        return result;
    }

    public struct function setRedirectEnabled(required string id, required boolean enabled) {
        var result = {};
        var message = {};
        if (m.validateCSRFTokens(context='set_redirect_enabled')) {
            try {
                var redirect = m.getBean('redirect').loadBy(redirectId=id);
                redirect.setEnabled(enabled);
                var result = redirect.save();

                var errors = result.get('errors');
                if (isDefined('errors') && structCount(errors)) {
                    action = 'set_redirect_enabled';
                    var messageContent = '<ul>';
                    for (var errorKey in errors)
                        messageContent &= '<li>#errors[errorKey]#</li>';
                    messageContent &= '</ul>';
                    message = {
                        type = 'error',
                        content = messageContent
                    };
                } else {
                    message = {
                        type = 'success',
                        content = "Enabled set to #enabled#."
                    };
                }
            } catch (any e) {
                message = {
                    type = 'error',
                    content = e.message
                };
            }
        } else {
            message = {
                type = 'error',
                content = "Unable to save due to invalid CSRF token."
            };
        }
        result.action = 'redirect_list';
        result.message = message;
        return result;
    }

    /**
     * Returns a struct {found, redirect, url}.
     **/
    public struct function getRedirectURL(siteID, protocol, domain, filePath) {
        // get all the redirects that could match (not checking regular expressions)
        // NOTE: siteID test is unnecessary, it's added by Mura
        var feed = m.getFeed('redirect')
            .where()
            .prop('enabled').isEQ(true)
            .andOpenGrouping()
                .prop('sourceProtocolValue').null()
                .orProp('sourceProtocolValue').isEQ(protocol)
            .closeGrouping()
            .andOpenGrouping()
                .prop('sourceDomainValue').null()
                .orProp('sourceDomainRegexp').isEQ(true)
                .orProp('sourceDomainValue').isEQ(domain)
            .closeGrouping()
            .andOpenGrouping()
                .prop('sourcePathValue').null()
                .orProp('sourcePathRegexp').isEQ(true)
                .orProp('sourcePathValue').isEQ(filePath)
            .closeGrouping();
        var redirects = feed.getIterator();
        var siteBean = m.getBean('site').loadBy(siteid=siteID);
        var siteProtocol = siteBean.getUseSSL() ? 'https' : 'http';
        var siteDomain = siteBean.getDomain();
        // check regular expressions and replace backreferences if needed
        // (references are to the domain and the path expressions, domain first)
        while (redirects.hasNext()) {
            var redirect = redirects.next();
            var target = redirect.getTargetURL();
            var matchIndex = 1;
            if (redirect.getSourceDomainValue() neq '' && redirect.getSourceDomainRegexp()) {
                var domainRegexp = redirect.getSourceDomainValue();
                domainRegexp = domainRegexp.replace('$domain',
                    siteDomain.replace('.', '\.'));
                try {
                    var results = domain.reFindNoCase(domainRegexp, 1, true);
                    if (results.pos[1] == 0)
                        continue;
                    if (target.find("\") > 0) {
                        for (var i=2; i<=results.pos.len(); i++) {
                            var value = domain.mid(results.pos[i], results.len[i]);
                            target = target.replace("\#matchIndex#", value);
                            matchIndex++;
                        }
                    }
                } catch (any e) {
                    writeLog("MuraRedirect: bad regular expression: #domainRegexp# for site #siteID#");
                    continue;
                }
            }
            if (redirect.getSourcePathValue() neq '' && redirect.getSourcePathRegexp()) {
                var pathRegexp = redirect.getSourcePathValue();
                try {
                    var results = filePath.reFindNoCase(pathRegexp, 1, true);
                    if (results.pos[1] == 0)
                        continue;
                    if (target.find("\") > 0) {
                        for (var i=2; i<=results.pos.len(); i++) {
                            var value = filePath.mid(results.pos[i], results.len[i]);
                            target = target.replace("\#matchIndex#", value);
                            matchIndex++;
                        }
                    }
                } catch (any e) {
                    writeLog("MuraRedirect: bad regular expression: #pathRegexp# for site #siteID#");
                    continue;
                }
            }
            target = target.replace('$protocol', siteProtocol);
            target = target.replace('$domain', siteDomain);
            target = target.replace('$primary', "#siteProtocol#://#siteDomain#");
            return {
                found: true,
                redirect: redirect,
                url: target
            };
        }
        return {
            found: false
        };
    }
}
