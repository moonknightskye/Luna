(function( $window, $document ) {
 "use strict";

      var utility = $window.utility;
 
      $window.App = (function(){

            function init(){};

            function activatePage( ){

              var app_content = utility.getElement("app_content", "id");
              var webview;
              var avplayer;

              $window.URL = $window.URL || $window.webkitURL;

              utility.getElement( "icon0", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"default"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });
              utility.getElement( "icon1", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"bluemoon"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });
              utility.getElement( "icon2", "id" ).addEventListener( "click", function() {
                iOS.changeIcon({name:"redmoon"}).then(function(result){
                  iOS.debug( "iOS.changeIcon: " + result );
                },function(error){
                  iOS.debug( "iOS.changeIcon: " + error );
                })
              });

              utility.getElement( "getvideo2", "id" ).addEventListener( "click", function() {
                  iOS.getVideoFile({
                    filename:   "video 2.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    iOS.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        300
                        },
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( avplayer2 ){

                      iOS.getMainWebview().appendAVPlayer({
                        avplayer: avplayer2,
                        isFixed: false
                      }).then( function(result){
                        iOS.debug( "appendAVPlayer: " + result )
                      });


                      iOS.debug( "iOS.getNewAVPlayer: " +  avplayer2.getID());
                    }, function(error){
                      iOS.debug( error );
                    })



                  },function(error){
                    iOS.debug( error );
                  });


              });

              utility.getElement( "getvideo1", "id" ).addEventListener( "click", function() {
                  
                  iOS.getVideoFile({
                    filename:   "video 7_4k_60fps.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    iOS.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( _avplayer ){
                      
                      avplayer = _avplayer;

                      iOS.getMainWebview().appendAVPlayer({
                        avplayer: avplayer,
                        isFixed: true
                      }).then( function(result){
                        iOS.debug( "appendAVPlayer: " + result )
                      });


                      iOS.debug( "iOS.getNewAVPlayer: " +  avplayer.getID());
                    }, function(error){
                      iOS.debug( error );
                    })



                  },function(error){
                    iOS.debug( error );
                  });


              });

              utility.getElement( "play", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.play().then( function(result){
                    iOS.debug( "avplayer.play: " + result );
                  });
                }
              });
              utility.getElement( "pause", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.pause().then( function(result){
                    iOS.debug( "avplayer.pause: " + result );
                  });
                }
              });
              utility.getElement( "seek", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.seek({seconds:2.0}).then( function(result){
                    iOS.debug( "avplayer.seek: " + result );
                  }, function(error){
                    iOS.debug( "avplayer.seek: " + error );
                  });
                }
              });


              utility.getElement( "getVideo", "id" ).addEventListener( "click", function() {
                // iOS.takeVideo({from:"VIDEO_LIBRARY"}).then( function(videoFile){
                //   iOS.debug( "iOS.takeVideo:" );


                //     videoFile.getFullResolutionDOM().then( function( DOM ){
                //       iOS.debug( "videoFile.getBase64Binary: YAY" );

                //       document.body.appendChild( DOM );

                //     }, function(error){
                //       iOS.debug( "videoFile.getBase64Binary: " + error );
                //     });

                // }, function(error){
                //   iOS.debug( "iOS.takeVideo: " + error );
                // });

                iOS.getVideoFile({
                    filename:   "video 1.mp4", //1,2,3,6
                    path_type:  "document"
                  }).then(function( videoFile ){
                    iOS.debug( "iOS.takeVideo:" +  videoFile.getFilename() +  videoFile.getFileExtension());

                    // console.log( videoFile )

                    videoFile.getFullResolutionDOM().then( function( DOM ){
                      iOS.debug( "videoFile.getBase64Binary: YAY" );

                      document.body.appendChild( DOM );

                    }, function(error){
                      iOS.debug( "videoFile.getBase64Binary: " + error );
                    });

                  },function(error){
                    iOS.debug( error );
                  });
              });




              utility.getElement( "takePhoto", "id" ).addEventListener( "click", function() {
                iOS.takePhoto({from:"CAMERA"}).then( function(imageFile){
                    iOS.debug( "iOS.takePhoto: OK" );

                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });
                    // imageFile.getFullResolutionDOM().then( function( DOM ){
                    //   iOS.debug( "imageFile.getBase64Binary: YAY" );

                    //   document.body.appendChild( DOM );

                    // }, function(error){
                    //   iOS.debug( "imageFile.getBase64Binary: " + error );
                    // });

                    imageFile.getEXIFInfo().then( function(value){
                      iOS.debug( value );
                    }, function(error){
                      iOS.debug( "imageFile.getEXIFInfo: " + error );
                    });

                }, function(error){
                    iOS.debug( "iOS.takePhoto: " + error );
                });
              });

              utility.getElement( "getPhoto", "id" ).addEventListener( "click", function() {
                  iOS.takePhoto({from:"PHOTO_LIBRARY"}).then( function(imageFile){

                    iOS.debug( "webview.takePhoto: " + imageFile.getFilename() + " " + imageFile.getFileExtension());


                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:50}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:10}).then( function( DOM ){
                      iOS.debug( "imageFile.getResizedDOM: YAY" );
                      document.body.appendChild( DOM );
                    }, function(error){
                      iOS.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      iOS.debug( "imageFile.getBase64Binary: YAY" );

                      document.body.appendChild( DOM );

                    }, function(error){
                      iOS.debug( "imageFile.getBase64Binary: " + error );
                    });

                    imageFile.getEXIFInfo().then( function(value){
                      iOS.debug( value );
                    }, function(error){
                      iOS.debug( "imageFile.getEXIFInfo: " + error );
                    });



                  }, function(error){
                    iOS.debug( "webview.takePhoto: " + error );
                  })
              });



              utility.getElement( "close", "id" ).addEventListener( "click", function() {
                  webview.setProperty( {frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:0
                    }, { duration:1.0, delay:0 } ).then(function(result){
                      iOS.debug( "webview.setProperty: " + result );
                      iOS.closeWebview( webview ).then(function(result){
                        iOS.debug( "webview.closeWebview: " + result );
                      });
                  });
              });

              utility.getElement( "move", "id" ).addEventListener( "click", function() {

                  iOS.getVideoFile({
                    filename:   "sample.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    iOS.debug( "iOS.getVideoFile:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    video_file.move({
                      to:  "movefolder",
                      isOverwrite: true
                    }).then(function(url){
                      iOS.debug("file.moveFile: " + video_file.getFilePath())
                    }, function(error){
                      iOS.debug("file.moveFile: " + error)
                    })


                  },function(error){

                    iOS.getVideoFile({
                      filename:   "sample.mp4",
                      path:       "movefolder", 
                      path_type:  "document"
                    }).then(function( video_file ){
                      iOS.debug( "iOS.getVideoFile: " +  video_file.getFilename() + " " + video_file.getFileExtension() );

                      video_file.move({
                        to:  "",
                        isOverwrite: true
                      }).then(function(url){
                        iOS.debug("file.moveFile: " + video_file.getFilePath())
                      }, function(error){
                        iOS.debug("file.moveFile: " + error)
                      })


                    },function(error){
                      iOS.debug( error );
                    });

                  });
              });

              utility.getElement( "rename", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "rename.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: (old filename) " +  file.getFilename());

                    file.rename({
                      filename:  "newname.mp4"
                    }).then(function(url){
                      iOS.debug( "iOS.getFile: (new filename) " +  file.getFilename());
                    }, function(error){
                      iOS.debug("file.renameFile: " + error)
                    })
                  },function(error){
                    //iOS.debug( error );

                    iOS.getFile({
                      filename:   "newname.mp4",
                      path_type:  "document"
                    }).then(function( file ){
                      iOS.debug( "iOS.getFile: (old filename) " +  file.getFilename());

                      file.rename({
                        filename:  "rename.mp4"
                      }).then(function(url){
                        iOS.debug( "iOS.getFile: (new filename) " +  file.getFilename());
                      }, function(error){
                        iOS.debug("file.renameFile: " + error)
                      })
                    },function(error){
                      iOS.debug( error );
                    });

                  });
              });


              utility.getElement( "copy", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "video 1.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: " +  file.getFilename());

                    file.copy({
                      relative:  "copyfolder"
                    }).then(function(url){
                      iOS.debug("file.copyFile: " + url)
                    }, function(error){
                      iOS.debug("file.copyFile: " + error)
                    })

                  },function(error){
                    iOS.debug( error );
                  });
              });

              utility.getElement( "delete", "id" ).addEventListener( "click", function() {

                  iOS.getFile({
                    filename:   "video 1.mp4",
                    path: "copyfolder",
                    path_type:  "document"
                  }).then(function( file ){
                    iOS.debug( "iOS.getFile: " +  file.getFilename());

                    file.delete().then(function(result){
                      iOS.debug("file.delete: " + result)
                    }, function(error){
                      iOS.debug("file.delete: " + error)
                    })

                  },function(error){
                    iOS.debug( error );
                  });
              });

              utility.getElement( "download", "id" ).addEventListener( "click", function() {

                iOS.newDownloadFile({
                    path:       "https://i.ytimg.com/vi/3R2uvJqWeVg/maxresdefault.jpg",
                    isOverwrite: false
                }).then( function( download_file ){

                  iOS.debug("iOS.getFile: OK " + download_file.getID())

                  download_file.onDownloaded().then( function(result){
                    iOS.debug("iOS.onDownloaded: " + result)
                  }, function(error){
                    iOS.debug("iOS.onDownloaded: " + error)
                  });
                  download_file.onDownload().then( function(result){
                    iOS.debug("iOS.onDownload: " + result)
                  }, function(error){
                    iOS.debug("iOS.onDownload: " + error)
                  });
                  download_file.onDownloading(function(progress){
                    //iOS.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    iOS.debug( "download_file.onDownloading: " + result );
                  }, function(error){
                    iOS.debug( "download_file.onDownloading: " + error );
                  });



                  download_file.download({save_path:"Downloads"}).then(function(result){
                    iOS.debug("iOS.download: " + result)
                  },function(error){
                    iOS.debug("iOS.download: " + error)
                  })

                }, function(error){
                  iOS.debug( "iOS.getFile: " + error );
                });

              });



              utility.getElement( "show", "id" ).addEventListener( "click", function() {

                iOS.getHTMLFile({
                    filename:   "subindex.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    iOS.debug( "iOS.getHTMLFile: " + html_file.getFilename() );

                    iOS.getNewWebview({
                      html_file: html_file,
                      property: {
                        frame: {
                          height:   320,
                          y:        0
                        },
                        opacity:    0
                      }
                    }).then( function( result ){

                      webview = result;

                      iOS.debug( "iOS.getNewWebview: " + webview.getID() );

                      webview.onLoad().then(function(result){
                        iOS.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        iOS.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        iOS.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        iOS.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   320,
                            y:        100
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          iOS.debug( "webview.setProperty: " + result );
                        });

                      });

                      webview.load().then(function(result){
                        iOS.debug( "webview.load: " + result );
                      });

                    },function( error ){
                      iOS.debug( error )
                    });


                }, function(error){
                    iOS.debug( error )
                })

              });


            };

            


            return {
              init: init,
              activatePage: activatePage
            };
      })();

























 
 })( typeof window !== "undefined" ? window : this, document );
