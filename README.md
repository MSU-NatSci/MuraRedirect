# MuraRedirect

Mura 7.1 plugin to manage redirections within Mura administration and keep usage statistics.
Supports regular expressions.

Variables: `$protocol` (primary protocol), `$domain` (primary domain), `$primary` (primary protocol and domain)

## Note about the path trailing slash
Mura adds a slash at the end of the URL if there is not one already.
To match, all source paths should end with a `/`.
The trailing slash can be removed by using a regular expression,
for instance `^(.*)/` to capture all the path without the trailing slash.

## Usage examples

### Change a page path
These paths are exact, `/a/b/` will not be affected.  
Path: `/a/`  
Target: `/b/`

### Change a path using a regular expression
Path: `^/a/(.*)`  
Path regular expression: `checked`  
Target: `/b/\1`

### Redirect a domain to a specific path in the primary protocol and domain
Domain: `a.com`  
Target: `$primary/b`

### Redirect a domain to primary protocol and domain, preserving the path
Domain: `a.com`  
Path: `^(.*)`  
Path regular expression: `checked`  
Target: `$primary\1`

### Redirect all other domains to primary protocol and domain, preserving the path
Domain: `^(?!$domain)`  
Domain regular expression: `checked`  
Path: `^(.*)`  
Path regular expression: `checked`  
Target: `$primary\1`

### Redirect to a different domain, preserving the protocol and the path
Domain: `a.com`  
Path: `^(.*)`  
Path regular expression: `checked`  
Target: `//b.com\1`

### Redirect a path to a different domain, removing the added trailing slash
Path: `^(/a.*)/`  
Path regular expression: `checked`  
Target: `https://b.com\1`

### Redirect to primary domain, preserving the protocol and the path
Domain: `a.com`  
Path: `^(.*)`  
Path regular expression: `checked`  
Target: `//$domain\1`

### Redirect to HTTPS, preserving the domain and the path
Protocol: http  
Domain: `^(.*)`  
Domain regular expression: `checked`  
Path: `^(.*)`  
Path regular expression: `checked`  
Target: `https://\1\2`
