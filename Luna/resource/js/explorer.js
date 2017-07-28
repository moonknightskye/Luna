
(function( $window, $document, $parent ) {
	"use strict";

	if ( typeof $window.apollo11 === "undefined" ) {
        console.error( "Apollo11 is needed to run Explorer", "ERROR" );
        return;
    }

	if ( typeof $window.explorer !== "undefined" ) {
        console.error( "Explorer has already been initialized", "ERROR" );
        return;
    } else {
        console.info( "[Happy Coding from Explorer]" );
    }

	$window.explorer = (function() {
		
		function ajax( param ) {
			return new Promise( function ( resolve, reject ) {
	            var xmlHttp = new XMLHttpRequest();
			    xmlHttp.onreadystatechange = function() {
			        if (xmlHttp.readyState == 4) {
			        	if(xmlHttp.status == 200) {
			        		resolve( xmlHttp.response );
			        	} else {
			        		if( param.responseType && param.responseType === 'json' ) {
			        			reject( xmlHttp.response );
			        		} else {
			        			reject("Status Code " + xmlHttp.status + " : " + xmlHttp.response);
			        		}
			        	}
			        }
			    }
			    xmlHttp.responseType = param.responseType;
			    xmlHttp.open(param.type, param.url, param.asynchronous || true); // true for asynchronous 
			    if( param.headers ) {
	            	$window.apollo11.forEveryKey(param.headers, function(value, key){
	            		xmlHttp.setRequestHeader(key, value);
	            	});
	            }
			    xmlHttp.send( param.data || null );
	        });
		};

		return {
			ajax	: ajax
		}
	})();

})( typeof window !== "undefined" ? window : this, window.document, typeof window !== "undefined" ? window.parent : this.parent );
