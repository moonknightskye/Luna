/**
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: April 212, 2017    Updated: XXX XX, XXXX
    Apollo11 Javascript Utility (utility lite version)
    v 1.0.0  a
**/

(function( $window, $document, $parent ) {
	"use strict";

	if ( typeof $window.apollo11 !== "undefined" ) {
        console.error( "Apollo11 has already been initialized", "ERROR" );
        return;
    }

	$window.apollo11 = (function(){

		function isUndefined( param ) {
            return ( typeof param === "undefined" );
        };

        function getElement( param, type, loc ) {
            type = ( type || "CLASS" ).toUpperCase();
            loc = loc || $document;
            switch ( type ) {
                default:
                case "CLASS":
                    return loc.getElementsByClassName( param );
                    break;
                case "ID":
                    return loc.getElementById( param );
                    break;
                case "TAG":
                    return loc.getElementsByTagName( param );
                    break;
                case "DATA":
                    if( Object.prototype.toString.call( param ) === "[object String]" ) {
                        return loc.querySelectorAll( "[data-" + param + "]" );
                    } else if ( Object.prototype.toString.call( param ) === "[object Object]" ) {
                        var _str = "";
                        forEveryKey( param, function( value, key ){
                            _str += "[data-" + key + "='"+ value +"']";
                        });
                        if( _str.length > 0 ) {
                            return loc.querySelectorAll( _str );
                        }
                    }
                    break;
                case "SELECT":
                    return loc.querySelector( param );
                    break;
                case "ALL":
                    return loc.querySelectorAll( param );
                    break;
            }
        };

        function forEvery( param, fn ) {
            if ( isUndefined( param ) || isUndefined( fn ) ) {
                return;
            }
            if ( Object.prototype.toString.call( param ) === "[object Object]" ) {
                param = [ param ];
            }  else if ( Object.prototype.toString.call( param ) === "[object Number]" ) {
                var _param = [];
                for( var j = 1; j <= param; j++ ) {
                    _param.push( j );
                }
                param = _param;
            } else if ( Object.prototype.toString.call( param ) !== "[object Array]" ) {
                param = Array.prototype.slice.call( param, 0 );
            }
            var _return;
            param.some(function( val,  i ) {
                _return = fn( val, i );
                if ( !isUndefined( _return ) ) {
                    return true;
                }
            });
            return _return || false;
        };

        function forEveryKey( param, fn ) {
            if ( isUndefined( param ) || isUndefined( fn ) ) {
                return;
            }
            var _return;
            forEvery( Object.keys( param ), function( val ) {
                _return = fn( param[ val ], val );
                if ( !isUndefined( _return ) ) {
                    return true;
                }
            });
            return _return || false;
        };

        function mergeJSON( obj1, obj2, isBackupDuplicate ) {
            var obj3 = {};
            forEveryKey( obj2, function( value, key ) {
                obj3[ key ] = value;
            });
            forEveryKey( obj1, function( value, key ) {
                if ( isBackupDuplicate ) {
                    if ( obj3.hasOwnProperty( key ) ) {
                        obj3[ key + "__super" ] = obj3[ key ];
                    }
                }
                obj3[ key ] = value;
            });
            return obj3;
        };

        function prependJSONDOM( param, loc, fn ) {
            _insertJSONDOM( param, loc, "prependDOM", fn );
        };

        function appendJSONDOM( param, loc, fn ) {
            _insertJSONDOM( param, loc, "appendDOM", fn );
        };

        function JSONtoDOM( data ) {
            var dom;
            if ( isUndefined( data[ "tag" ] ) ) {
                console.log( "Must contain tag parameter", "ERROR" );
                console.log( data );
                return undefined;
            }
            if( !isUndefined( data[ "namespace" ] ) ) {
                dom = $document.createElementNS( _INTERNAL_DATA.namespaceURI[ data[ "namespace" ] ], data[ "tag" ].toLowerCase()  );
            } else {
                dom = $document.createElement( data[ "tag" ].toLowerCase() );
            }
            forEveryKey( data, function( value, key ) {
                switch( key ) {
                    case "tag":
                    case "namespace":
                        break;
                    case "class":
                        if ( Object.prototype.toString.call( value ) === "[object String]"  ) {
                            value = value.split(" ");
                        }
                        forEvery( value, function( _class ) {
                            if ( _class === "" ) {
                                return;
                            }
                            dom.classList.add( _class );
                        });
                        break;
                    case "data":
                        forEvery( value, function( data ) {
                            forEveryKey( data, function( value2, key2 ) {
                                dom.dataset[key2] = ( Object.prototype.toString.call( value2 ) === "[object Object]"  ) ? JSON.stringify( value2 ) : value2;
                            });
                        });
                        break;
                    case "style":
                        dom.setAttribute( key , value );
                        break;
                    case "text":
                        dom.textContent = value;
                        break;
                    case "children":
                        forEvery( value, function( child ) {
                            appendJSONDOM( child, dom );
                        });
                        break;
                    case "events":
                        forEveryKey( value, function( value2, key2 ) {
                            dom.addEventListener( key2, value2 );
                        });
                        break;
                    case "html":
                        dom.innerHTML = value;
                        break;
                    case "xlink":
                        forEveryKey( value, function( value2, key2 ) {
                            dom.setAttributeNS( _INTERNAL_DATA.namespaceURI[ key ], key2, value2 );
                        });
                        break;
                    default:
                        dom.setAttribute( key , value );
                        break;
                };
            });
            return dom;
        };

        function prependDOM( child, parent, fn ) {
            parent = parent || getParent( child );

            if ( !parent.firstChild ) {
                appendDOM( child, parent, fn )
                return;   
            }
            addOneTimeEventListener( parent, "DOMNodeInserted", fn );
            parent.insertBefore( child, parent.firstChild );
        };
        
        function appendDOM( child, parent, fn ) {
            parent = parent || getParent( child );
            //addOneTimeEventListener( parent, "DOMNodeInserted", fn );
            var observer = new MutationObserver( function( mutations ) {
              mutations.forEach( function( mutation ) {
                if ( mutation.type === "childList" ) {
                    if ( fn ) {
                        fn();
                    }
                }
              });    
            });
            observer.observe( parent, { attributes: true, childList: true, characterData: true } );
            parent.appendChild( child );
        };
        
        function removeDOM( child, parent, fn ) {
            parent = parent || getParent( child );
            addOneTimeEventListener( parent, "DOMNodeRemoved", fn );
            parent.removeChild( child );
        };
        
        
        //TODO: removeEventListener is not available in arai
        function addOneTimeEventListener( elem, event, fn ) {
            if ( isUndefined( event ) || isUndefined( fn ) ) {
                return;
            }
            
            var _callback = function() {
                if ( elem.removeEventListener ) {
                    elem.removeEventListener( event, _callback );
                } else {
                    log("element cannot handle removeEventListener: " + event, "BUG");
                }
                fn();
            }
            elem.addEventListener( event, _callback );
        };

        function getParent( elem, fn ) {
            var _return;
            var parent = elem.parentElement;
            if ( parent.nodeName === "BODY" ) {
                return false;
            }
            if ( isUndefined( fn ) ) {
               return parent; 
            }
            ( function( _parent ) {
                _return = fn( _parent );
            })( parent );
            if ( !isUndefined( _return ) ) return _return;
    
            return getParent( parent, fn );
        };

        function base64ToBlob( base64, contentType, sliceSize ) {
            contentType = contentType || "";
            sliceSize = sliceSize || 512;
            var byteCharacters = $window.atob( base64 );
            var byteArrays = [];
            for ( var offset = 0; offset < byteCharacters.length; offset += sliceSize ) {
                var slice = byteCharacters.slice( offset, offset + sliceSize );
                var byteNumbers = new Array( slice.length );
                for ( var i = 0; i < slice.length; i++ ) {
                    byteNumbers[ i ] = slice.charCodeAt( i );
                }
                var byteArray = new Uint8Array( byteNumbers );
                byteArrays.push(byteArray);
            }
            return new Blob( byteArrays, { type: contentType } );
        };

        function base64ToObjectURL( base64, contentType ) {
            return $window.URL.createObjectURL( base64ToBlob( base64, contentType ) );
        };
        
        function isOniFrame() {
            try {
                return $window.self !== $window.top;
            } catch (e) {
                return true;
            }
        };

        function splice( parent, child, compareKey ) {
            var pos = - 1;
            forEvery(parent, function(_child, i) {
                if( compareKey ) {
                    if( child.hasOwnProperty(compareKey) &&  _child.hasOwnProperty(compareKey) ) {
                        if( child[ compareKey ] === _child[ compareKey ] ) {
                            pos = i;
                            return false;
                        }
                    }
                } else {
                    if( _child === child ) {
                        pos = i;
                        return false;
                    }
                }
            });
            if( pos > -1 ) {
                return parent.splice(pos, 1);
            }
        };

        // description = {class:"classname"} {id:"idname"}
        function waitUntilDOMReady( description, parent, timeoutseconds) {
            return new Promise( function ( resolve, reject ) {
                parent = parent || $document.body;
                var timeout = new Date().getTime() + ( ( timeoutseconds || 0.3 ) * 1000 );
                var DOM;
                function checkDOMReady(){
                    if( (new Date().getTime()) > timeout ) {
                        reject("[WARNING] Timeout. DOM may not exists here.");
                        console.log(description, parent);
                        return;
                    }
                    forEveryKey( description, function(value, key) {
                        if( key === "id" ) {
                            parent = $document;
                        }
                        DOM = getElement( value, key, parent );
                    });
                    if( DOM ) {
                        if( Object.prototype.toString.call( DOM ) === "[object HTMLElement]" ||
                            Object.prototype.toString.call( DOM ) === "[object HTMLDivElement]") {
                            resolve( DOM );
                            return;
                        } else if ( Object.prototype.toString.call( DOM ) === "[object HTMLCollection]" ) {
                            if( DOM.length > 0 ) {
                                resolve( DOM );
                                return;
                            }
                        }
                    }
                    $window.requestAnimationFrame( checkDOMReady );
                };
                $window.requestAnimationFrame( checkDOMReady );
            });
        };


        /**
            * BELOW ARE INTERNAL FUNCTIONS USED INSIDE THE LIBRARY
            * THIS SHOULD NOT BE OVERWRITTEN
            */
        var _INTERNAL_DATA = {
            namespaceURI: {
                svg: "http://www.w3.org/2000/svg",
                xlink: "http://www.w3.org/1999/xlink",
                html: "http://www.w3.org/1999/xhtml",
                xbl: "http://www.mozilla.org/xbl",
                xul: "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"
            } 
        };

        function _insertJSONDOM( param, loc, ftype, fn ) {
            loc = loc || $document.body;
            var dom;
            forEvery( param, function( data ) {
                dom = JSONtoDOM( data );
                if( !isUndefined( dom ) ) {
                    $window.apollo11[ ftype ]( dom, loc, ( isUndefined( fn ) ) ? fn : function() {
                        fn( dom );
                    });
                }
            });
        };

        return {
        	addOneTimeEventListener	: addOneTimeEventListener,
        	appendDOM				: appendDOM,
        	appendJSONDOM			: appendJSONDOM,
        	base64ToBlob			: base64ToBlob,
        	base64ToObjectURL		: base64ToObjectURL,
        	forEvery				: forEvery,
        	forEveryKey				: forEveryKey,
        	getElement				: getElement,
        	getParent				: getParent,
        	isUndefined				: isUndefined,
        	isOniFrame				: isOniFrame,
        	JSONtoDOM				: JSONtoDOM,
        	mergeJSON				: mergeJSON,
        	prependJSONDOM			: prependJSONDOM,
        	prependDOM				: prependDOM,
        	splice					: splice,
			removeDOM				: removeDOM,
            waitUntilDOMReady       : waitUntilDOMReady
        };

	})();

})( typeof window !== "undefined" ? window : this, document, typeof window !== "undefined" ? window.parent : this.parent );