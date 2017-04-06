/*
    Author: Mart Civil
    Email: mcivil@salesforce.com
    Date: Aug 8, 2015    Updated: Sept 5, 2016
    Native Javascript Utility
    v 2.0.0
*/

(function( $window, $document ) {
    "use strict";
    
    var self = $window.utility;
    
    if ( typeof self === "undefined" ) {
        console.error( "[ ERROR ] utility-css.js is dependent on utility.js" )
        return;
    };
    
    if ( !self.isUndefined( self.greetUtilityCSS ) ) {
        self.log( "utility-css.js has already been initialized", "ERROR" );
        return;
    }
    
    $window.utility = self.mergeJSON( (function() {
    
        function init() {
            self.log( "initialized utility-css.js on strict mode." );
        };
        
        function greetUtilityCSS() {
            self.log( "Hello utility-css.js" );
        };
        
        function prependJSONDOM( param, loc, fn ) {
            _insertJSONDOM( param, loc, "prependDOM", fn );
        };

        function appendJSONDOM( param, loc, fn ) {
            _insertJSONDOM( param, loc, "appendDOM", fn );
        };
        
        function getCSSRule( selectorText, type ) {
            if ( self.isRestrictedMode() ) {
                self.log( "Restricted access to styleSheets object", "ERROR" );
                return false;
            }
        
            type = type || "style";
            var cssKeyframesRule;
            if ( self.getPrefix().js === "Moz" ) {
                cssKeyframesRule = MozCSSKeyframesRule;
            } else {
                cssKeyframesRule = CSSKeyframesRule;
            }
            
            return self.forEveryKey( $document.styleSheets, function( rules ) {
                return self.forEveryKey( rules.cssRules || rules.rules, function( rule2 ) {
                    if ( rule2.constructor === CSSStyleRule && type === "style" ) {
                        if ( selectorText === rule2.selectorText ) {
                            return rule2;
                        }
                    } else if ( rule2.constructor === cssKeyframesRule && type === "keyframes" ) {
                        if ( rule2.name === selectorText ) {
                            return rule2.cssRules;
                        }
                    } else if ( rule2.constructor === CSSFontFaceRule && type === "font" ) {
                        if ( rule2.style.fontFamily === selectorText ) {
                            return rule2;
                        }
                    };
                });
            });
        };
        
        function extendSuperFunction() {
          $window.utility.extendSuperFunction__super();
          self.log("THIS IS THE EXTENDED extendSuperFunction");
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

        function JSONtoDOM( data ) {
            var dom;
            if ( self.isUndefined( data[ "tag" ] ) ) {
                self.log( "Must contain tag parameter", "ERROR" );
                self.log( data );
                return undefined;
            }
            if( !self.isUndefined( data[ "namespace" ] ) ) {
                dom = $document.createElementNS( _INTERNAL_DATA.namespaceURI[ data[ "namespace" ] ], data[ "tag" ].toLowerCase()  );
            } else {
                dom = $document.createElement( data[ "tag" ].toLowerCase() );
            }
            self.forEveryKey( data, function( value, key ) {
                switch( key ) {
                    case "tag":
                    case "namespace":
                        break;
                    case "class":
                        if ( value.constructor === String ) {
                            value = value.split(" ");
                        }
                        self.forEvery( value, function( _class ) {
                            if ( _class === "" ) {
                                return;
                            }
                            dom.classList.add( _class );
                        });
                        break;
                    case "data":
                        self.forEvery( value, function( data ) {
                            self.forEveryKey( data, function( value2, key2 ) {
                                dom.dataset[key2] = ( value2.constructor === Object ) ? JSON.stringify( value2 ) : value2;
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
                        self.forEvery( value, function( child ) {
                            appendJSONDOM( child, dom );
                        });
                        break;
                    case "events":
                        self.forEveryKey( value, function( value2, key2 ) {
                            dom.addEventListener( key2, value2 );
                        });
                        break;
                    case "html":
                        dom.innerHTML = value;
                        break;
                    case "xlink":
                        self.forEveryKey( value, function( value2, key2 ) {
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
        
        function _insertJSONDOM( param, loc, ftype, fn ) {
            loc = loc || $document.body;
            var dom;
            self.forEvery( param, function( data ) {
                dom = JSONtoDOM( data );
                if( !self.isUndefined( dom ) ) {
                    self[ ftype ]( dom, loc, ( self.isUndefined( fn ) ) ? fn : function() {
                        fn( dom );
                    });
                }
            });
        };
        
        
        
        self.onPageLoad( init );
        
        return{
            JSONtoDOM: JSONtoDOM,
            appendJSONDOM: appendJSONDOM,
            extendSuperFunction: extendSuperFunction,
            greetUtilityCSS: greetUtilityCSS,
            getCSSRule: getCSSRule,
            prependJSONDOM: prependJSONDOM
        };
       })(), self, true );
        
})( typeof window !== "undefined" ? window : this, document );