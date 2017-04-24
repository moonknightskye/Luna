(function( $window, $document, $parent ) {
    "use strict";

    if ( typeof $window.luna !== "undefined" ) {
        console.error( "luna.js has already been initialized", "ERROR" );
        return;
    }
    
    var COMMAND = {
        NEW_WEB_VIEW                : 0,
        LOAD_WEB_VIEW               : 1,
        ANIMATE_WEB_VIEW            : 2,
        WEB_VIEW_ONLOAD             : 3,
        WEB_VIEW_ONLOADED           : 4,
        WEB_VIEW_ONLOADING          : 5,
        CLOSE_WEB_VIEW              : 6,
        TAKE_PHOTO                  : 7,
        GET_FILE                    : 8,
        GET_HTML_FILE               : 9,
        GET_IMAGE_FILE              : 10,
        GET_EXIF_IMAGE              : 11,
        GET_BASE64_BINARY           : 12,
        GET_BASE64_RESIZED          : 13,
        GET_VIDEO_BASE64_BINARY     : 14,
        GET_VIDEO                   : 15,
        NEW_AV_PLAYER               : 16,
        APPEND_AV_PLAYER            : 17,
        AV_PLAYER_PLAY              : 18,
        AV_PLAYER_PAUSE             : 19,
        AV_PLAYER_SEEK              : 20,
        TAKE_VIDEO                  : 21,
        MEDIA_PICKER                : 22,
        CHANGE_ICON                 : 23,
        GET_VIDEO_FILE              : 24,
        DOWNLOAD                    : 25,
        GET_ZIP_FILE                : 26,
        ONDOWNLOAD                  : 27,
        ONDOWNLOADED                : 28,
        ONDOWNLOADING               : 29,
        MOVE_FILE                   : 30,
        RENAME_FILE                 : 31,
        COPY_FILE                   : 32,
        DELETE_FILE                 : 33,
        UNZIP                       : 34,
        ON_UNZIP                    : 35,
        ON_UNZIPPING                : 36,
        ON_UNZIPPED                 : 37,
        GET_FILE_COL                : 38,
        SHARE_FILE                  : 39,
        ZIP                         : 40,
        ON_ZIP                      : 41,
        ON_ZIPPING                  : 42,
        ON_ZIPPED                   : 43
    };
    var CommandPriority = {
        CRITICAL                    : 0,
        HIGH                        : 1,
        NORMAL                      : 2,
        LOW                         : 3,
        BACKGROUND                  : 4
    };
    var OPTION = {
        PHOTO_LIBRARY              : "PHOTO_LIBRARY",
        CAMERA                     : "CAMERA",
        VIDEO_LIBRARY              : "VIDEO_LIBRARY",
        CAMCORDER                  : "CAMCORDER"
    };
    var FILEEXTENSION = {
        PNG:                "png",
        JPG:                "jpg",
        JPEG:               "jpeg",
        GIF:                "gif",
        HTML:               "html",
        ZIP:                "zip",
        UNSUPPORTED:        "unsupported"
    };
    var STATUS = {
        SELF: -3,
        SYSTEM: -2,
        INIT: -1,
        ON_QUEUE: 0,
        RUNNING: 1,
        DONE: 2,
        WEBVIEW_INIT: 200,
        WEBVIEW_LOAD: 201,
        WEBVIEW_LOADING: 202,
        WEBVIEW_LOADED: 203,
        IOS_INIT: 100,
        IOS_READY: 101,
        RESOLVE: 1,
        REJECT: 0,
        UPDATE: 2
    };
 
    $window.luna = (function(){

        function setLightningId( lightning_id ) {
            if( $window.sputnik1 ) {
                _INTERNAL_DATA.lightning_id = lightning_id;
                $window.sputnik1.lightningStrike( _INTERNAL_DATA.lightning_id );
            }
        };
        
        function getLightningId() {
            return _INTERNAL_DATA.lightning_id;
        }
        
        function init( webview_id ) {
            _INTERNAL_DATA.debugDOM = apollo11.getElement( ".debug", "SELECT" ) || $document.body;
            _INTERNAL_DATA.webview = new Webview({
                parent_webview_id:  STATUS.SYSTEM,
                webview_id:         webview_id
            });
            _INTERNAL_DATA.status = STATUS.IOS_READY;
            apollo11.forEvery( _INTERNAL_DATA.initFns, function( initFn ) {
                initFn();
            });
        };

        function onReady( fn ) {
            if( _INTERNAL_DATA.status ===  STATUS.IOS_READY ) {
                $window.setTimeout( fn );
            } else {
                _INTERNAL_DATA.initFns.push( fn );
            }
        };

        function runJSCommand( cmd ) {
            (function( _cmd ) {
                if( $window.luna[ _cmd.command ] && $window.luna[ _cmd.command ].constructor === Function  ) {
                    $window.luna[ _cmd.command ]( _cmd.params );
                }
            })( JSON.parse( cmd ) );
        };

        function processJSCommand( value ) {
            CommandProcessor.process( value );
        };

        function fallback( value ) {
            console.log("This is a fallback method", value);
        };

        function getFileCollection( parameter ) {
            var command = new Command({
                command_code:   COMMAND.GET_FILE_COL,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                return new FileCollection( result );
            });
            return CommandProcessor.queue( command );
        };

        function getFile( parameter ) {
            _setPathType( parameter );
            var command = new Command({
                command_code:   COMMAND.GET_FILE,
                priority        : CommandPriority.LOW,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                parameter = apollo11.mergeJSON( result, parameter );
                return new File( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getHtmlFile( parameter ) {
            _setPathType( parameter );
            var command = new Command({
                command_code:   COMMAND.GET_HTML_FILE,
                priority        : CommandPriority.LOW,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                parameter = apollo11.mergeJSON( result, parameter );
                return new HtmlFile( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getImageFile(parameter) {
            _setPathType( parameter );
            var command = new Command({
                command_code:   COMMAND.GET_IMAGE_FILE,
                priority        : CommandPriority.LOW,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                parameter = apollo11.mergeJSON( result, parameter );
                return new ImageFile( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getVideoFile(parameter) {
            _setPathType( parameter );
            var command = new Command({
                command_code:   COMMAND.GET_VIDEO_FILE,
                priority        : CommandPriority.LOW,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                parameter = apollo11.mergeJSON( result, parameter );
                return new VideoFile( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getZipFile(parameter) {
            _setPathType( parameter );
            var command = new Command({
                command_code:   COMMAND.GET_ZIP_FILE,
                priority        : CommandPriority.LOW,
                parameter:      parameter
            });
            command.onResolve( function( result ) {
                parameter = apollo11.mergeJSON( result, parameter )
                return new ZipFile( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getNewWebview( parameter ) {
            var param = { html_file: parameter.html_file.toJSON() };
            if( !apollo11.isUndefined( parameter.property ) ) {
                param.property = parameter.property
            }
            var command = new Command({
                command_code:   COMMAND.NEW_WEB_VIEW,
                priority            : CommandPriority.CRITICAL,
                parameter:      param
            });
            command.onResolve( function( webview_id ) {
                parameter.webview_id = webview_id;
                return new Webview( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function closeWebview( webview ) {
            var command = new Command({
                command_code        : COMMAND.CLOSE_WEB_VIEW,
                priority            : CommandPriority.CRITICAL,
                target_webview_id   : webview.getID()
            });
            return CommandProcessor.queue( command );
        };

        function takePhoto( option ) {
            if( apollo11.isUndefined( option ) ) {
                option = {};
            }
            if( apollo11.isUndefined( option.from ) ) {
                option.from = OPTION.CAMERA;
            } else {
                switch (option.from.trim().toUpperCase()) {
                    case "PHOTO_LIBRARY":
                        option.from = OPTION.PHOTO_LIBRARY;
                        break;
                    case "CAMERA":
                        option.from = OPTION.CAMERA;
                        break;
                    default:
                        option.from = OPTION.PHOTO_LIBRARY;
                };
            }
            var command = new Command({
                command_code:       COMMAND.MEDIA_PICKER,
                parameter:          option
            });
            command.onResolve( function( result ) {
                return new ImageFile( result );
            });
            return CommandProcessor.queue( command );
        };

        function takeVideo( option ) {
            if( apollo11.isUndefined( option ) ) {
                option = {};
            }
            if( apollo11.isUndefined( option.from ) ) {
                option.from = OPTION.CAMCORDER;
            } else {
                switch (option.from.trim().toUpperCase()) {
                    case "VIDEO_LIBRARY":
                        option.from = OPTION.VIDEO_LIBRARY;
                        break;
                    case "CAMCORDER":
                        option.from = OPTION.CAMCORDER;
                        break;
                    default:
                        option.from = OPTION.VIDEO_LIBRARY;
                };
            }
            var command = new Command({
                command_code:       COMMAND.MEDIA_PICKER,
                parameter:          option
            });
            command.onResolve( function( result ) {
                return new VideoFile( result );
            });
            return CommandProcessor.queue( command );
        };

        function takeVideo_( parameter ) {
            var command = new Command({
                command_code:   COMMAND.GET_VIDEO,
                parameter:      parameter
            });
            command.onResolve( function( file_path ) {
                parameter.file_path = file_path;
                return new VideoFile( parameter );
            });
            return CommandProcessor.queue( command );
        };

        function getNewAVPlayer( parameter ) {
            var param = { video_file: parameter.video_file.toJSON() };
            if( !apollo11.isUndefined( parameter.property ) ) {
                param.property = parameter.property
            }
            var command = new Command({
                command_code:   COMMAND.NEW_AV_PLAYER,
                priority            : CommandPriority.CRITICAL,
                parameter:      param
            });
            command.onResolve( function( avplayer_id ) {
                parameter.avplayer_id = avplayer_id;
                return new AVPlayer( parameter );
            });
            return CommandProcessor.queue( command );
        };


        function debug( param ) {
            if( param.constructor === Object ) {
                param = JSON.stringify( param )
            }
            apollo11.appendJSONDOM( {
                tag:"DIV",
                text: param
            }, _INTERNAL_DATA.debugDOM );
        };

        function getMainWebview() {
            if( !apollo11.isUndefined( _INTERNAL_DATA.webview ) ) {
                return _INTERNAL_DATA.webview;
            }
            return false;
        };

        function changeIcon( parameter ) {
            var command = new Command({
                command_code:   COMMAND.CHANGE_ICON,
                parameter:      parameter
            });
            return CommandProcessor.queue( command );
        };

        var _INTERNAL_DATA = {
            status:     STATUS.IOS_INIT,
            initFns:    [],
            webview:    undefined,
            debugDOM   : undefined,
            lightning_id: undefined
        };

        var _setPathType = function( param ) {
            var type = "document";
            if( param.path ) {
                if( param.path.startsWith("http") || param.path.startsWith("ftp") ) {
                    type = "url";
                } else {
                    return
                }
            }
            param.path_type = type;
        };

        return {
            changeIcon: changeIcon,
            closeWebview: closeWebview,
            debug: debug,
            fallback: fallback,
            getFile: getFile,
            init: init,
            getHtmlFile: getHtmlFile,
            getImageFile: getImageFile,
            getFileCollection: getFileCollection,
            getLightningId : getLightningId,
            getMainWebview: getMainWebview,
            getNewAVPlayer: getNewAVPlayer,
            getNewWebview: getNewWebview,
            getVideoFile: getVideoFile,
            getZipFile: getZipFile,
            onReady: onReady,
            processJSCommand: processJSCommand,
            setLightningId: setLightningId,
            takePhoto: takePhoto,
            takeVideo: takeVideo,
            runJSCommand: runJSCommand
        };
    })();

    function AVPlayer( param ) {
        var avplayer = {};
        var _INTERNAL_DATA = {
            id:                 param.avplayer_id,
            parentWebviewID:    param.parent_webview_id || STATUS.SYSTEM,
            video_file:         undefined,
            property:           param.property || { isOpaque: false }
        };

        function init() {
            if( !apollo11.isUndefined( param.video_file ) ) {
                avplayer.setVideoFile( param.video_file );
            }
        };

        avplayer.play = function() {
            var command = new Command({
                command_code        : COMMAND.AV_PLAYER_PLAY,
                priority            : CommandPriority.HIGH,
                parameter           : {
                    avplayer_id     : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };
        avplayer.pause = function() {
            var command = new Command({
                command_code        : COMMAND.AV_PLAYER_PAUSE,
                priority            : CommandPriority.HIGH,
                parameter           : {
                    avplayer_id     : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };
        avplayer.seek = function( param ) {
            var command = new Command({
                command_code        : COMMAND.AV_PLAYER_SEEK,
                priority            : CommandPriority.HIGH,
                parameter           : {
                    avplayer_id     : this.getID(),
                    seconds         : param.seconds || 0
                }
            });
            return CommandProcessor.queue( command );
        };

        avplayer.getID = function() {
            return _INTERNAL_DATA.id;
        };
        avplayer.setID = function( avplayer_id ) {
            _INTERNAL_DATA.id = avplayer_id;
        };

        avplayer.setVideoFile = function( video_file ) {
            if ( video_file.isClass ) {
                _INTERNAL_DATA.video_file = video_file;
            } else {
                _INTERNAL_DATA.video_file = new VideoFile(video_file);
            }
        };
        avplayer.getVideoFile = function(){
            return _INTERNAL_DATA.video_file;
        };
        avplayer.getParentWebViewID = function() {
            return _INTERNAL_DATA.parentWebviewID;
        };

        init();
        return avplayer;
    };

    // parent_webview_id, webview_id
    function Webview( param ) {
        var webview = {};
        var _INTERNAL_DATA = {
            status:             STATUS.WEBVIEW_INIT,
            id:                 param.webview_id,
            parentWebviewID:    param.parent_webview_id || STATUS.SYSTEM,
            html_file:          undefined,
            property:           param.property || { isOpaque: false },
            av_player:          []
        };

        function init() {
            if( _INTERNAL_DATA.parentWebviewID === STATUS.SYSTEM ) {
                webview.setStatus(  STATUS.WEBVIEW_LOADED );
            }
            if( !apollo11.isUndefined( param.html_file ) ) {
                webview.setHtmlFile( param.html_file );
            }
        };

        webview.appendAVPlayer = function( param ) {
            var command = new Command({
                command_code:       COMMAND.APPEND_AV_PLAYER,
                priority            : CommandPriority.CRITICAL,
                target_webview_id:  this.getID(),
                parameter: {
                    avplayer_id: (!apollo11.isUndefined(param.avplayer)) ? param.avplayer.getID() : -1,
                    isFixed:        param.isFixed || false
                }
            });
            command.onResolve( function(result){
                _INTERNAL_DATA.av_player.push( param.avplayer );
                return result;
            });
            return CommandProcessor.queue( command );
        };  

        webview.load = function() {
            var command = new Command({
                command_code:       COMMAND.LOAD_WEB_VIEW,
                priority            : CommandPriority.BACKGROUND,
                target_webview_id:  this.getID()
            });
            this.setStatus( STATUS.WEBVIEW_LOAD )
            return CommandProcessor.queue( command );
        };

        webview.close = function() {
            var command = new Command({
                command_code:       COMMAND.CLOSE_WEB_VIEW,
                priority            : CommandPriority.CRITICAL,
                target_webview_id:  this.getID()
            });
            return CommandProcessor.queue( command );
        };

        webview.onLoad = function() {
            var command = new Command({
                command_code        : COMMAND.WEB_VIEW_ONLOAD,
                priority            : CommandPriority.CRITICAL,
                target_webview_id   : this.getID()
            });
            return CommandProcessor.queue( command );
        };

        webview.onLoaded = function() {
            var command = new Command({
                command_code:       COMMAND.WEB_VIEW_ONLOADED,
                priority            : CommandPriority.CRITICAL,
                target_webview_id:  this.getID()
            });
            return CommandProcessor.queue( command );
        };

        webview.onLoading = function( fn ) {
            var command = new Command({
                command_code:       COMMAND.WEB_VIEW_ONLOADING,
                priority            : CommandPriority.CRITICAL,
                target_webview_id:  this.getID()
            });
            command.onUpdate( fn )
            return CommandProcessor.queue( command );
        };

        webview.setHtmlFile = function( html_file ) {
            if ( html_file.isClass ) {
                _INTERNAL_DATA.html_file = html_file;
            } else {
                _INTERNAL_DATA.html_file = new HtmlFile(html_file);
            }
            _INTERNAL_DATA.status = STATUS.WEBVIEW_INIT;
        };
        webview.getHtmlFile = function(){
            return _INTERNAL_DATA.html_file;
        };

        webview.setStatus = function( status ) {
            if( webview.getStatus() < status ) {
                _INTERNAL_DATA.status = status;
                return true;
            }
            return false;
        };
        webview.getStatus = function() {
            return _INTERNAL_DATA.status;
        };

        webview.getParentWebViewID = function() {
            return _INTERNAL_DATA.parentWebviewID;
        };

        webview.getID = function() {
            return _INTERNAL_DATA.id;
        };
        webview.setID = function( webview_id ) {
            if( webview.getStatus() != STATUS.WEBVIEW_INIT ) {
                _INTERNAL_DATA.id = webview_id;
                webview.setStatus(  STATUS.WEBVIEW_LOAD );
                return true;
            }
            return false;
        };

        webview.setProperty = function( property, animation ) {
            if( apollo11.isUndefined( animation ) ) {
                animation = {};
            }
            if ( apollo11.isUndefined( animation.duration ) ) {
                animation.duration = 0;
            }
            _INTERNAL_DATA.property = apollo11.mergeJSON( property, _INTERNAL_DATA.property );

            var command = new Command({
                command_code            : COMMAND.ANIMATE_WEB_VIEW,
                priority                : CommandPriority.CRITICAL,
                target_webview_id       : this.getID(),
                parameter: {
                    property:           this.getProperty(),
                    animation:          animation
                }
            });
            return CommandProcessor.queue( command );
        };
        webview.getProperty = function() {
            return _INTERNAL_DATA.property;
        };

        init();
        return webview;
    };

    function VideoFile( param ) {
        var file = {};

        function init(){
            file.setObjectType( "VideoFile" );
        };

        file.greet = function(){
            this.greet__super();
            luna.debug("HELLO3");
        };

        file.getFullResolutionDOM = function() {
            var chunks = [];
            var command = new Command({
                command_code    : COMMAND.GET_VIDEO_BASE64_BINARY,
                priority        : CommandPriority.LOW,   
                parameter       : this.toJSON()
            });
            command.onUpdate( function(base64_chunk){
                chunks.push( apollo11.base64ToBlob( base64_chunk, "application/octet-binary" ) );
            });
            command.onResolve( function( result ) {
                return generateDOM( chunks, file.getFileExtension() );
            });
            return CommandProcessor.queue( command );
        };

        var generateDOM = function( chunks, fileExtension ) {
            var DOM = {
                tag: "VIDEO",
                src: $window.URL.createObjectURL( new Blob( chunks, { type: "video/" + fileExtension } ) )
            };
            return apollo11.JSONtoDOM( DOM );
        };



        file = apollo11.mergeJSON( file, new File(param), true );
        init();

        return file;
    };

    function HtmlFile( param ) {
        var file = {};

        function init(){
            file.setObjectType( "HtmlFile" );
        };

        file.greet = function(){
            this.greet__super();
        };

        file = apollo11.mergeJSON( file, new File(param), true );
        init();

        return file;
    };

    function ZipFile( param ) {
        var file = {};

        function init(){
            file.setObjectType( "ZipFile" );
        };

        file.greet = function(){
            this.greet__super();
        };

        file.onUnzip = function() {
            var command = new Command({
                command_code    : COMMAND.ON_UNZIP,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };
        file.onUnzipped = function() {
            var command = new Command({
                command_code    : COMMAND.ON_UNZIPPED,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };
        file.onUnzipping = function( fn ) {
            var command = new Command({
                command_code    : COMMAND.ON_UNZIPPING,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            command.onUpdate( fn );
            return CommandProcessor.queue( command );
        };

        file.unzip = function( param ) {
            var command = new Command({
                command_code    : COMMAND.UNZIP,
                priority        : CommandPriority.BACKGROUND,
                parameter       : {
                    file        : this.toJSON(),
                    to          : param.to,
                    password    : param.password,
                    isOverwrite : param.isOverwrite || false
                }
            });
            return CommandProcessor.queue( command );
        };



        file = apollo11.mergeJSON( file, new File(param), true );
        init();

        return file;
    };

    function ImageFile( param ) {
        var file = {};

        var _INTERNAL_DATA = {
        };

        function init(){
            file.setObjectType( "ImageFile" );
        };

        file.getEXIFInfo = function(){
            var command = new Command({
                command_code:   COMMAND.GET_EXIF_IMAGE,
                parameter:      this.toJSON()
            });
            command.onResolve( function( exif_info ) {
                return exif_info;
            });
            return CommandProcessor.queue( command );
        };

        var generateDOM = function( base64, fileExtension ) {
            var contentType = "image/" + fileExtension;
            var DOM = {
                tag: "IMG",
                src: apollo11.base64ToObjectURL( base64, contentType )
            };
            return apollo11.JSONtoDOM( DOM );
        };

        file.getFullResolutionDOM = function() {
            var command = new Command({
                command_code:   COMMAND.GET_BASE64_BINARY,
                priority        : CommandPriority.LOW,
                parameter:      this.toJSON()
            });
            command.onResolve( function( base64_value ) {
                return generateDOM( base64_value, file.getFileExtension() );
            });
            return CommandProcessor.queue( command );
        };

        file.getResizedDOM = function( option ) {
            option              = option || {};
            option.quality      = option.quality || 100;
            option.width        = option.width || option.height || 100;
            option.height       = option.height || option.width || 100;
            var command = new Command({
                command_code:   COMMAND.GET_BASE64_RESIZED,
                priority        : CommandPriority.LOW,
                parameter:      {
                    image_file: this.toJSON(),
                    option:     option
                }
            });
            command.onResolve( function( base64_resized ) {
                var ext = ( option.quality >= 100 ) ? FILEEXTENSION.PNG: FILEEXTENSION.JPG
                return generateDOM( base64_resized, ext );
            });
            return CommandProcessor.queue( command );
        };

        file.greet = function(){
            this.greet__super();
            luna.debug("HELLO2");
        };

        file = apollo11.mergeJSON( file, new File(param), true );
        init();
        return file;
    };

    function FileCollection( param ) {
        var fileCol = {};

        var _INTERNAL_DATA = {
            collection_id       : param.collection_id,
            path                : param.path,
            path_type           : param.path_type || "document",
            file_path           : param.file_path,
            directories         : param.directories || [],
            files               : []
        };

        function init() {
            if( !apollo11.isUndefined(param.files) ) {
                apollo11.forEvery( param.files, function(file){
                    switch( file.object_type ) {
                        case "HtmlFile":
                            fileCol.addFile( new HtmlFile( file ) );
                            break;
                        case "VideoFile":
                            fileCol.addFile( new VideoFile( file ) );
                            break;
                        case "ImageFile":
                            fileCol.addFile( new ImageFile( file ) );
                            break;
                        case "ZipFile":
                            fileCol.addFile( new ZipFile( file ) );
                            break;
                        default:
                            fileCol.addFile( new File( file ) );
                            break;
                    };
                });
            }
        };

        fileCol.toJSON = function(){
            var getFilesJSON = function(){
                var JSON = [];
                apollo11.forEvery( fileCol.getFiles(), function(file){
                    JSON.push( file.toJSON() );
                });
                return JSON;
            };
            var getDirectories = function(){
                var JSON = [];
                apollo11.forEvery( fileCol.getDirectories(), function(directory){
                    JSON.push( directory );
                });
                return JSON;
            };
            return {
                collection_id   : this.getID(),
                path            : this.getPath(),
                path_type       : this.getPathType(),
                file_path       : this.getFilePath(),
                files           : getFilesJSON(),
                directories     : getDirectories()
            };
        };

        fileCol.getID = function() {
            return _INTERNAL_DATA.collection_id;
        };

        fileCol.setFilePath = function( file_path ) {
            _INTERNAL_DATA.file_path = file_path;
        };
        fileCol.getFilePath = function() {
            return _INTERNAL_DATA.file_path;
        };
        fileCol.setPath = function( path ) {
            _INTERNAL_DATA.path = path;
        };
        fileCol.getPath = function( ) {
            return _INTERNAL_DATA.path;
        };

        fileCol.setPathType = function( path_type ) {
            _INTERNAL_DATA.path_type = path_type;
        };
        fileCol.getPathType = function( ) {
            return _INTERNAL_DATA.path_type;
        };

        fileCol.getDirectories = function(){
            return _INTERNAL_DATA.directories;
        };

        fileCol.getFiles = function() {
            return _INTERNAL_DATA.files;
        };

        fileCol.share = function( parameter ) {
            var command = new Command({
                command_code    : COMMAND.SHARE_FILE,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_collection : this.toJSON(),
                    includeSubdirectoryFiles: parameter.includeSubdirectoryFiles || false
                }
            });
            return CommandProcessor.queue( command );
        };

        fileCol.addFile = function( file ) {
            if (file.isClass) {
                _INTERNAL_DATA.files.push( file )
            }
        };

        init();
        return fileCol;
    };

    function File( param ) {
        var file = {
            isClass: true
        };
        var _INTERNAL_DATA = {
            file_id             : param.file_id,
            filename            : param.filename,
            path                : param.path,         // folder/name, http://www.mysite.com
            path_type           : param.path_type || "document",    //url, bundle, document
            file_extension      : param.file_extension,  //zip, html, png, mp4
            status              : STATUS.INIT,
            file_path           : param.file_path,
            object_type         : param.object_type || "File"
        };

        function init() {
            if( _INTERNAL_DATA.filename && _INTERNAL_DATA.filename.length > 0 && !_INTERNAL_DATA.file_extension) {
                _INTERNAL_DATA.file_extension = _INTERNAL_DATA.filename.substring( _INTERNAL_DATA.filename.lastIndexOf( "." ) + 1 );
            }
            if( _INTERNAL_DATA.path && (_INTERNAL_DATA.path.startsWith("http") || _INTERNAL_DATA.path.startsWith("ftp")) ) {
                _INTERNAL_DATA.path_type = "url";
            }
        };

        file.greet = function(){
            luna.debug("HELLO1");
        };

        file.setObjectType = function( object_type ) {
            _INTERNAL_DATA.object_type = object_type;
        };
        file.objectType = function() {
            return _INTERNAL_DATA.object_type;
        };

        file.getID = function() {
            return _INTERNAL_DATA.file_id;
        };

        file.toJSON = function(){
            return {
                filename        : this.getFilename(),
                file_id         : this.getID(),
                path            : this.getPath(),
                path_type       : this.getPathType(),
                file_path       : this.getFilePath(),
                file_extension  : this.getFileExtension(),
                object_type     : this.objectType()
            };
        };

        file.getFileExtension = function() {
            return _INTERNAL_DATA.file_extension;
        };

        file.setFilePath = function( file_path ) {
            _INTERNAL_DATA.file_path = file_path;
        };
        file.getFilePath = function() {
            return _INTERNAL_DATA.file_path;
        };

        file.setFilename = function( filename ) {
            _INTERNAL_DATA.filename = filename;
        };
        file.getFilename = function( ) {
            return _INTERNAL_DATA.filename;
        };

        file.setPath = function( path ) {
            _INTERNAL_DATA.path = path;
        };
        file.getPath = function( ) {
            return _INTERNAL_DATA.path;
        };

        file.setPathType = function( path_type ) {
            _INTERNAL_DATA.path_type = path_type;
        };
        file.getPathType = function( ) {
            return _INTERNAL_DATA.path_type;
        };

        file.setStatus = function( status ) {
            _INTERNAL_DATA.status = status;
        };
        file.getStatus = function( ) {
            return _INTERNAL_DATA.status;
        };

        file.onDownload = function() {
            var command = new Command({
                command_code    : COMMAND.ONDOWNLOAD,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    id          : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };

        file.onDownloading = function(fn) {
            var command = new Command({
                command_code    : COMMAND.ONDOWNLOADING,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    id          : this.getID()
                }
            });
            command.onUpdate( fn );
            return CommandProcessor.queue( command );
        };

        file.onDownloaded = function() {
            var command = new Command({
                command_code    : COMMAND.ONDOWNLOADED,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    id          : this.getID()
                }
            });
            command.onResolve( function(result){
                _INTERNAL_DATA = apollo11.mergeJSON( result, _INTERNAL_DATA );
                return _INTERNAL_DATA;
            });
            return CommandProcessor.queue( command );
        };

        file.download = function( parameter ) {
            var command = new Command({
                command_code    : COMMAND.DOWNLOAD,
                priority        : CommandPriority.BACKGROUND,
                parameter       : {
                    to          : parameter.to,
                    file        : this.toJSON(),
                    isOverwrite : parameter.isOverwrite || false,
                }
            });
            command.onResolve( function( download_id ) {
                return download_id;
            });
            return CommandProcessor.queue( command );
        };

        file.move = function( param ) {
            var command = new Command({
                command_code    : COMMAND.MOVE_FILE,
                parameter       : {
                    file        : this.toJSON(),
                    to          : param.to || "",
                    isOverwrite : param.isOverwrite || false
                }
            });
            command.onResolve( function( new_file_path ) {
                file.setPath( param.to || "" );
                file.setFilePath( new_file_path );
                return new_file_path;
            });
            return CommandProcessor.queue( command );
        };

        file.rename = function( param ) {
            var command = new Command({
                command_code    : COMMAND.RENAME_FILE,
                parameter       : {
                    file        : this.toJSON(),
                    filename    : param.filename
                }
            });
            command.onResolve( function( new_file_path ) {
                file.setFilename( param.filename );
                file.setFilePath( new_file_path );
                return new_file_path;
            });
            return CommandProcessor.queue( command );
        };

        file.copy = function( param ) {
            var command = new Command({
                command_code    : COMMAND.COPY_FILE,
                parameter       : {
                    file        : this.toJSON(),
                    to          : param.to || ""
                }
            });
            return CommandProcessor.queue( command );
        };

        file.share = function() {
            var command = new Command({
                command_code    : COMMAND.SHARE_FILE,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file        : this.toJSON()
                }
            });
            return CommandProcessor.queue( command );
        };

        file.delete = function( ) {
            var command = new Command({
                command_code    : COMMAND.DELETE_FILE,
                parameter       : {
                    file        : this.toJSON(),
                }
            });
            command.onResolve( function( result ) {
                file.setFilePath( undefined );
                return result;
            });
            return CommandProcessor.queue( command );
        };

        file.zip = function( param ) {
            var command = new Command({
                command_code    : COMMAND.ZIP,
                priority        : CommandPriority.BACKGROUND,
                parameter       : {
                    file        : this.toJSON(),
                    filename    : param.filename,
                    isOverwrite : param.isOverwrite || false
                }
            });
            return CommandProcessor.queue( command );
        };

        file.onZip = function() {
            var command = new Command({
                command_code    : COMMAND.ON_ZIP,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            return CommandProcessor.queue( command );
        };
        file.onZipped = function() {
            var command = new Command({
                command_code    : COMMAND.ON_ZIPPED,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            command.onResolve( function( result ) {
                return new ZipFile( result );
            });
            return CommandProcessor.queue( command );
        };
        file.onZipping = function( fn ) {
            var command = new Command({
                command_code    : COMMAND.ON_ZIPPING,
                priority        : CommandPriority.CRITICAL,
                parameter       : {
                    file_id     : this.getID()
                }
            });
            command.onUpdate( fn );
            return CommandProcessor.queue( command );
        };

        init();

        return file;
    };

    var CommandProcessor = (function(){
        function init(){}

        function queue( command ) {
            return new Promise( function ( resolve, reject ) {
                var response = function( result ) {
                    if( result.status === STATUS.RESOLVE ) {
                        command.resolve( resolve, result );
                    } else if( result.status === STATUS.REJECT ) {
                        command.reject( reject, result );
                    } else if ( result.status === STATUS.UPDATE ) {
                        command.update( result );
                    }
                };

                command.onResponse( response );
                _queue( command )
            });
        };

        function run( func_name, message ) {
            //$window.webkit.messageHandlers[ func_name ].postMessage( message );
            if( $window.sputnik1 ) {
                sputnik1.sendSOS( func_name, message );
            }
        };

        function resolve( data ) {
            apollo11.appendJSONDOM({tag:"DIV",text:JSON.stringify(data)});
        };

        function _queue( command ) {
            run( "webcommand", command.prepare() );
            command.setStatus( STATUS.ON_QUEUE );
            _INTERNAL_DATA.queue.push( command );
        };

        function remove( command ) {
            apollo11.splice( _INTERNAL_DATA.queue, command );
        };

        function generateCommandID(){
            _INTERNAL_DATA.command_id += 1;
            return _INTERNAL_DATA.command_id;
        };

        function process( param ) {
            var command = getCommand( param.command_id );
            if( command ) {
                command.respond( param.result );
            }
        };

        function getCommand( command_id ) {
            return apollo11.forEvery( _INTERNAL_DATA.queue, function( command ){
                if( command.getID() === command_id ) {
                    return command;
                }
            })
        };

        var _INTERNAL_DATA = {
            command_id: 0,
            queue: []
        };

        return {
            generateCommandID: generateCommandID,
            getCommand: getCommand,
            queue: queue,
            process: process,
            resolve: resolve,
            remove: remove,
            run: run
        };
    })();


    function Command( param ) {
        var command = {};

        var _INTERNAL_DATA = {
            status              : STATUS.INIT,
            command_id          : CommandProcessor.generateCommandID(),
            source_webview_id   : luna.getMainWebview().getID(),
            target_webview_id   : undefined,
            command_code        : param.command_code,
            priority            : param.priority,
            parameter           : param.parameter || {},
            callback_method     : param.callback_method || "processJSCommand",
            respondFn           : param.onResponse,
            resolveFn           : param.onResolve,
            rejectFn            : param.onReject,
            updateFn            : param.onUpdate
        };


        function init() {
            command.setTargetWebviewID( param.target_webview_id );
            if( apollo11.isUndefined( param.priority ) ) {
                _INTERNAL_DATA.priority = CommandPriority.NORMAL;
            }
        };

        command.prepare = function() {
            return JSON.stringify({
                command_code        : this.getCommandCode(),
                command_id:         this.getID(),
                priority            : this.getPriority(),
                source_webview_id:  this.getSourceWebviewID(),
                target_webview_id:  this.getTargetWebviewID(),
                parameter:          this.getParameter(),
                callback_method:    this.getCallbackMethod()
            })
        };

        command.getPriority = function() {
            return _INTERNAL_DATA.priority;
        };

        command.onResponse = function( fn ) {
            _INTERNAL_DATA.respondFn = fn;
        };

        command.onResolve = function( fn ) {
            _INTERNAL_DATA.resolveFn = fn;
        };

        command.onReject = function( fn ) {
            _INTERNAL_DATA.rejectFn = fn;
        };

        command.onUpdate = function( fn ) {
            _INTERNAL_DATA.updateFn = fn;
        };

        command.update = function( result ) {
            if( !apollo11.isUndefined( _INTERNAL_DATA.updateFn ) ) {
                _INTERNAL_DATA.updateFn( result.value );
            } else {
                console.log( result.value );
            }
        };

        command.respond = function( result ) {
            if( !apollo11.isUndefined( _INTERNAL_DATA.respondFn ) ) {
                _INTERNAL_DATA.respondFn( result );
            } else {
                console.log( result );
            }
        };

        command.resolve = function( resolve, result ) {
            if( apollo11.isUndefined( _INTERNAL_DATA.resolveFn ) ) {
                resolve( result.value );
            } else {
                resolve( _INTERNAL_DATA.resolveFn( result.value ) );
            }
            CommandProcessor.remove( this )
        };
        command.reject = function( reject, result ) {
            if( apollo11.isUndefined( _INTERNAL_DATA.rejectFn ) ) {
                reject( result.message );
            } else {
                reject( _INTERNAL_DATA.rejectFn( result.message ) );
            }
            CommandProcessor.remove( this )
        };


        command.setCallbackMethod= function( callback_method ) {
            _INTERNAL_DATA.callback_method = callback_method;
        };
        command.getCallbackMethod= function() {
            return _INTERNAL_DATA.callback_method;
        };

        command.setCommandCode = function( command_code ) {
            _INTERNAL_DATA.command_code = command_code;
        };
        command.getCommandCode = function() {
            return _INTERNAL_DATA.command_code;
        };

        command.getSourceWebviewID = function(){
            return _INTERNAL_DATA.source_webview_id;
        };

        command.setTargetWebviewID = function( target_webview_id ) {
            if( apollo11.isUndefined( target_webview_id ) ) {
                target_webview_id = STATUS.SELF;
            }
            target_webview_id = parseInt( target_webview_id );
            if( target_webview_id === STATUS.SELF ) {
                _INTERNAL_DATA.target_webview_id = luna.getMainWebview().getID();
            } else {
                _INTERNAL_DATA.target_webview_id = target_webview_id;
            }
        };
        command.getTargetWebviewID = function() {
            return _INTERNAL_DATA.target_webview_id;
        };

        command.setStatus = function( status ) {
            _INTERNAL_DATA.status = status;
        };

        command.setParameter = function( parameter ) {
            if( !apollo11.isUndefined( parameter ) ) {
                _INTERNAL_DATA.parameter = parameter;
            }
        };
        command.getParameter = function() {
            return _INTERNAL_DATA.parameter;
        };

        command.getID = function() {
            return _INTERNAL_DATA.command_id;
        };

        init();
        return command;
    };




})( typeof window !== "undefined" ? window : this, document, typeof window !== "undefined" ? window.parent : null );