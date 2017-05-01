(function( $window, $document ) {
  "use strict";
 
      $window.App = (function(){

            function init(){};

            function activatePage( luna ) {

              var app_content = utility.getElement("app_content", "id");
              var debug = utility.getElement(".debug", "SELECT");
              var webview;
              var avplayer;

              $window.URL = $window.URL || $window.webkitURL;

              utility.getElement( "icon0", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"de"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });
              utility.getElement( "icon1", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"bluemoon"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });
              utility.getElement( "icon2", "id" ).addEventListener( "click", function() {
                luna.changeIcon({name:"redmoon"}).then(function(result){
                  luna.debug( "luna.changeIcon: " + result );
                },function(error){
                  luna.debug( "luna.changeIcon: " + error );
                })
              });

              utility.getElement( "getvideo2", "id" ).addEventListener( "click", function() {
                  luna.getVideoFile({
                    filename:   "video 2.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    luna.debug( "luna.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    luna.getNewAVPlayer({
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

                      luna.getMainWebview().appendAVPlayer({
                        avplayer: avplayer2,
                        isFixed: false
                      }).then( function(result){
                        luna.debug( "appendAVPlayer: " + result )
                      });


                      luna.debug( "luna.getNewAVPlayer: " +  avplayer2.getID());
                    }, function(error){
                      luna.debug( error );
                    })



                  },function(error){
                    luna.debug( error );
                  });


              });

              utility.getElement( "getvideo1", "id" ).addEventListener( "click", function() {
                  
                  luna.getVideoFile({
                    filename:   "video 7_4k_60fps.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    luna.debug( "luna.takeVideo:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    luna.getNewAVPlayer({
                      video_file: video_file,
                      property: {
                        opacity:    1,
                        autoPlay:   true,
                        mute:       false
                      }
                    }).then(function( _avplayer ){
                      
                      avplayer = _avplayer;

                      luna.getMainWebview().appendAVPlayer({
                        avplayer: avplayer,
                        isFixed: true
                      }).then( function(result){
                        luna.debug( "appendAVPlayer: " + result )
                      });


                      luna.debug( "luna.getNewAVPlayer: " +  avplayer.getID());
                    }, function(error){
                      luna.debug( error );
                    })



                  },function(error){
                    luna.debug( error );
                  });


              });

              utility.getElement( "play", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.play().then( function(result){
                    luna.debug( "avplayer.play: " + result );
                  });
                }
              });
              utility.getElement( "pause", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.pause().then( function(result){
                    luna.debug( "avplayer.pause: " + result );
                  });
                }
              });
              utility.getElement( "seek", "id" ).addEventListener( "click", function() {
                if( avplayer ) {
                  avplayer.seek({seconds:2.0}).then( function(result){
                    luna.debug( "avplayer.seek: " + result );
                  }, function(error){
                    luna.debug( "avplayer.seek: " + error );
                  });
                }
              });


              utility.getElement( "getVideo", "id" ).addEventListener( "click", function() {
                luna.takeVideo({from:"VIDEO_LIBRARY"}).then( function(videoFile){
                  luna.debug( "luna.takeVideo:" );

                    videoFile.getFullResolutionDOM().then( function( DOM ){
                      luna.debug( "videoFile.getBase64Binary: YAY" );

                      debug.appendChild( DOM );

                    }, function(error){
                      luna.debug( "videoFile.getBase64Binary: " + error );
                    });

                }, function(error){
                  luna.debug( "luna.takeVideo: " + error );
                });

                // luna.getVideoFile({
                //     filename:   "video 1.mp4", //1,2,3,6
                //     path_type:  "document"
                //   }).then(function( videoFile ){
                //     luna.debug( "luna.takeVideo:" +  videoFile.getFilename());

                //     // console.log( videoFile )

                //     videoFile.getFullResolutionDOM().then( function( DOM ){
                //       luna.debug( "videoFile.getBase64Binary: YAY" );

                //       debug.appendChild( DOM );

                //     }, function(error){
                //       luna.debug( "videoFile.getBase64Binary: " + error );
                //     });

                //   },function(error){
                //     luna.debug( error );
                //   });
              });




              utility.getElement( "takePhoto", "id" ).addEventListener( "click", function() {
                luna.takePhoto({from:"CAMERA"}).then( function(imageFile){
                    luna.debug( "luna.takePhoto: OK" );
                    luna.debug( "luna.takePhoto: " + imageFile.getFilePath());

                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    // imageFile.move({
                    //     to:  "Camera Roll",
                    //     isOverwrite: true
                    // }).then(function(url){
                    //     luna.debug("file.moveFile: " + imageFile.getFilePath())
                    // }, function(error){
                    //     luna.debug("file.moveFile: " + imageFile)
                    // })

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      luna.debug( "imageFile.getBase64Binary: YAY" );

                      debug.appendChild( DOM );

                    }, function(error){
                      luna.debug( "imageFile.getBase64Binary: " + error );
                    });

                    // imageFile.getEXIFInfo().then( function(value){
                    //   luna.debug( value );
                    // }, function(error){
                    //   luna.debug( "imageFile.getEXIFInfo: " + error );
                    // });

                }, function(error){
                    luna.debug( "luna.takePhoto: " + error );
                });
              });

              utility.getElement( "getPhoto", "id" ).addEventListener( "click", function() {
                  luna.takePhoto({from:"PHOTO_LIBRARY"}).then( function(imageFile){

                    luna.debug( "webview.takePhoto: " + imageFile.getFilename() + " " + imageFile.getFileExtension());


                    imageFile.getResizedDOM({quality:100}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:50}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: YAY" );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                    imageFile.getFullResolutionDOM().then( function( DOM ){
                      luna.debug( "imageFile.getBase64Binary: YAY" );

                      debug.appendChild( DOM );

                    }, function(error){
                      luna.debug( "imageFile.getBase64Binary: " + error );
                    });

                    imageFile.getEXIFInfo().then( function(value){
                      luna.debug( value );
                    }, function(error){
                      luna.debug( "imageFile.getEXIFInfo: " + error );
                    });



                  }, function(error){
                    luna.debug( "webview.takePhoto: " + error );
                  })
              });



              utility.getElement( "close", "id" ).addEventListener( "click", function() {
                  webview.setProperty( {frame: {
                        height:   320,
                        y:        300
                      },
                      opacity:0
                    }, { duration:1.0, delay:0 } ).then(function(result){
                      luna.debug( "webview.setProperty: " + result );
                      luna.closeWebview( webview ).then(function(result){
                        luna.debug( "webview.closeWebview: " + result );
                      });
                  });
              });

              utility.getElement( "move", "id" ).addEventListener( "click", function() {

                  luna.getVideoFile({
                    filename:   "sample.mp4",
                    path_type:  "document"
                  }).then(function( video_file ){
                    luna.debug( "luna.getVideoFile:" +  video_file.getFilename() + " " + video_file.getFileExtension() );

                    video_file.move({
                      to:  "movefolder",
                      isOverwrite: true
                    }).then(function(url){
                      luna.debug("file.moveFile: " + video_file.getFilePath())
                    }, function(error){
                      luna.debug("file.moveFile: " + error)
                    })


                  },function(error){

                    luna.getVideoFile({
                      filename:   "sample.mp4",
                      path:       "movefolder", 
                      path_type:  "document"
                    }).then(function( video_file ){
                      luna.debug( "luna.getVideoFile: " +  video_file.getFilename() + " " + video_file.getFileExtension() );

                      video_file.move({
                        to:  "",
                        isOverwrite: true
                      }).then(function(url){
                        luna.debug("file.moveFile: " + video_file.getFilePath())
                      }, function(error){
                        luna.debug("file.moveFile: " + error)
                      })


                    },function(error){
                      luna.debug( error );
                    });

                  });
              });

              utility.getElement( "rename", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "rename.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: (old filename) " +  file.getFilename());

                    file.rename({
                      filename:  "newname.mp4"
                    }).then(function(url){
                      luna.debug( "luna.getFile: (new filename) " +  file.getFilename());
                    }, function(error){
                      luna.debug("file.renameFile: " + error)
                    })
                  },function(error){
                    //luna.debug( error );

                    luna.getFile({
                      filename:   "newname.mp4",
                      path_type:  "document"
                    }).then(function( file ){
                      luna.debug( "luna.getFile: (old filename) " +  file.getFilename());

                      file.rename({
                        filename:  "rename.mp4"
                      }).then(function(url){
                        luna.debug( "luna.getFile: (new filename) " +  file.getFilename());
                      }, function(error){
                        luna.debug("file.renameFile: " + error)
                      })
                    },function(error){
                      luna.debug( error );
                    });

                  });
              });


              utility.getElement( "copy", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "video 1.mp4",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: " +  file.getFilename());

                    file.copy({
                      to:  "copyfolder"
                    }).then(function(url){
                      luna.debug("file.copyFile: " + url)
                    }, function(error){
                      luna.debug("file.copyFile: " + error)
                    })

                  },function(error){
                    luna.debug( error );
                  });
              });

              utility.getElement( "delete", "id" ).addEventListener( "click", function() {

                  luna.getFile({
                    filename:   "video 1.mp4",
                    path: "copyfolder",
                    path_type:  "document"
                  }).then(function( file ){
                    luna.debug( "luna.getFile: " +  file.getFilename());

                    file.delete().then(function(result){
                      luna.debug("file.delete: " + result)
                    }, function(error){
                      luna.debug("file.delete: " + error)
                    })

                  },function(error){
                    luna.debug( error );
                  });

                  
              });

              utility.getElement( "download", "id" ).addEventListener( "click", function() {

                // luna.getFile({
                //   path    : "http://all-free-download.com/free-photos/download/english_love_picture_burning_165644_download.html"
                // }).then( function(file){

                //   luna.debug("luna.getFile: " + file.getFilePath())

                //   file.onDownload().then( function(result){
                //     luna.debug("file.onDownload: " + result)
                //   }, function(error){
                //     luna.debug("file.onDownload: " + error)
                //   });

                //   file.onDownloading(function(progress){
                //     luna.debug( "onDownloading: " + progress + "%" );
                //   }).then(function(result){
                //     luna.debug( "file.onDownloading: " + result );
                //   }, function(error){
                //     luna.debug( "file.onDownloading: " + error );
                //   });

                //   file.onDownloaded().then( function(result){
                //     luna.debug("file.onDownloaded: " + result)
                //   }, function(error){
                //     luna.debug("file.onDownloaded: " + error)
                //   });

                //   file.download({
                //     isOverwrite   : true
                //   }).then(function(result){
                //     luna.debug("file.download: ok" + result)
                //   },function(error){
                //     luna.debug("file.download: error" + error)
                //   });

                // }, function(error){
                //   luna.debug("luna.getFile: " + error)
                // })



                luna.getImageFile({
                  path    : "https://goo.gl/cl7FKy"
                }).then( function(file){

                  luna.debug("luna.getFile1: " )
                  luna.debug(file)

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload1: " + result)
                  }, function(error){
                    luna.debug("file.onDownload1: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading1: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading1: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading1: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded1: ")
                    luna.debug(result)

                    // file.copy({
                    //   to:  "copyfolder"
                    // }).then(function(url){
                    //   luna.debug("file.copyFile: " + url)
                    // }, function(error){
                    //   luna.debug("file.copyFile: " + error)
                    // })

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM1: " );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM1: " + error );
                    });

                    file.share().then(function(resut){
                      luna.debug("file.share: " + resut)
                    },function(error){
                      luna.debug("file.share: " + error)
                    });


                  }, function(error){
                    luna.debug("file.onDownloaded1: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    luna.debug("file.download1: " + resut)
                  },function(error){
                    luna.debug("file.download1: " + error)
                  });


                }, function(error){
                  luna.debug("luna.getFile1: " + error)
                })






                luna.getImageFile({
                  path    : "https://lumiere-a.akamaihd.net/v1/images/image_ccc4b657.jpeg"
                }).then( function(file){

                  luna.debug("luna.getFile: " + file.getFilePath())

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload: " + result)
                  }, function(error){
                    luna.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded: ")
                    luna.debug(result)

                    file.getResizedDOM({quality:10}).then( function( DOM ){
                      luna.debug( "imageFile.getResizedDOM: " );
                      debug.appendChild( DOM );
                    }, function(error){
                      luna.debug( "imageFile.getResizedDOM: " + error );
                    });

                  }, function(error){
                    luna.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true
                  }).then(function(resut){
                    luna.debug("file.download: " + resut)
                  },function(error){
                    luna.debug("file.download: " + error)
                  });

                }, function(error){
                  luna.debug("luna.getFile: " + error)
                })





              });



              utility.getElement( "show", "id" ).addEventListener( "click", function() {

                luna.getHtmlFile({
                    filename:   "subindex.html",
                    path:       "resource",
                    path_type:  "bundle"
                }).then( function( html_file ){
                    luna.debug( "luna.getHtmlFile: " );
                    luna.debug( html_file )

                    luna.getNewWebview({
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

                      luna.debug( "luna.getNewWebview: " + webview.getID() );

                      webview.load().then(function(result){
                        luna.debug( "webview.load: " + result );
                      });

                      webview.onLoad().then(function(result){
                        luna.debug( "webview.onLoad: " + result );
                      });

                      webview.onLoading(function(progress){
                        luna.debug( "Loading: " + progress + "%" );
                      }).then(function(result){
                        luna.debug( "webview.onLoading: " + result );
                      });

                      webview.onLoaded().then(function(result){
                        luna.debug( "webview.onLoaded: " + result );

                        webview.setProperty( {frame: {
                            height:   320,
                            y:        100
                          },
                          opacity:1.0
                        }, { duration:1.0, delay:0 } ).then(function(result){
                          luna.debug( "webview.setProperty: " + result );
                        });

                      });

                    },function( error ){
                      luna.debug( error )
                    });


                }, function(error){
                    luna.debug( error )
                })

              });


              utility.getElement( "unzip", "id" ).addEventListener( "click", function() {

                luna.getZipFile({
                  path    : "https://s3.amazonaws.com/data.openaddresses.io/runs/176076/br/am/statewide.zip"
                }).then( function(file){

                  luna.debug("luna.getFile: " )
                  luna.debug(file)

                  file.onDownload().then( function(result){
                    luna.debug("file.onDownload: " + result)
                  }, function(error){
                    luna.debug("file.onDownload: " + error)
                  });

                  file.onDownloading(function(progress){
                    luna.debug( "onDownloading: " + progress + "%" );
                  }).then(function(result){
                    luna.debug( "file.onDownloading: " + result );
                  }, function(error){
                    luna.debug( "file.onDownloading: " + error );
                  });

                  file.onDownloaded().then( function(result){
                    luna.debug("file.onDownloaded: ")
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                  }, function(error){
                    luna.debug("file.onDownloaded: " + error)
                  });

                  file.download({
                    isOverwrite   : true,
                  }).then(function(resut){
                    luna.debug("file.download: " + resut)
                  },function(error){
                    luna.debug("file.download: " + error)
                  });

                }, function(error){
                  luna.debug("luna.getFile: " + error)
                })


                luna.getZipFile({
                    filename:   "imagefiles.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    luna.debug( "luna.getZipFile: ");
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                });

                luna.getZipFile({
                    filename:   "myfolder.zip" //myfolder.zip imagefiles.zip
                }).then( function( file ){
                    luna.debug( "luna.getZipFile: ");
                    luna.debug(file)

                    file.onUnzip().then(function(result){
                      luna.debug("file.onUnzip: " + result)
                    }, function(error){
                      luna.debug("file.onUnzip: " + error)
                    })
                    file.onUnzipped().then(function(result){
                      luna.debug("file.onUnzipped: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipped: " + error)
                    })
                    file.onUnzipping(function(progress){
                      luna.debug("file.onUnzipping: " + progress)
                    }).then(function(result){
                      luna.debug("file.onUnzipping: " + result)
                    }, function(error){
                      luna.debug("file.onUnzipping: " + error)
                    })

                    file.unzip({
                      to: "unzipfolder"
                    }).then(function(result){
                      luna.debug("file.unzip: " + result)
                    }, function(error){
                      luna.debug("file.unzip: " + error)
                    })

                });
              });

              utility.getElement( "zip", "id" ).addEventListener( "click", function() {
                luna.getImageFile({
                  filename: "spiderman.jpg",
                  path_type: "document"
                }).then(function(file){

                  file.zip({
                    filename    : "spiderman.zip",
                    isOverwrite : true
                  }).then(function(result){
                    luna.debug("file.zip: " + result)
                  }, function(error){
                    luna.debug("file.zip: " + error)
                  })

                  file.onZip().then(function(result){
                    luna.debug("file.onZip: " + result)
                  }, function(error){
                    luna.debug("file.onZip: " + error)
                  })
                  file.onZipped().then(function(zipFile){
                    luna.debug("file.onZipped: ")
                    luna.debug( zipFile.toJSON() )
                  }, function(error){
                    luna.debug("file.onZipped: " + error)
                  })
                  file.onZipping(function(progress){
                    luna.debug("file.onZipping: " + progress)
                  }).then(function(result){
                    luna.debug("file.onZipping: " + result)
                  }, function(error){
                    luna.debug("file.onZipping: " + error)
                  });

                },function(error){
                  luna.debug("luna.getImageFile: " + error)
                });
              });



              utility.getElement( "filecol", "id" ).addEventListener( "click", function() {

                var listFiles = function( path ) {
                  luna.getFileCollection({
                    path: path,
                    path_type: "document"
                  }).then(function( fileCollection ){
                    luna.debug("luna.getFileCollection: ")
                    luna.debug( "No of Files: " + fileCollection.getFiles().length )

                    utility.forEvery( fileCollection.getFiles(), function(file){
                      
                      if(file.objectType() === "ImageFile") {
                        file.getResizedDOM({quality:100, height: 150}).then( function( DOM ){
                          luna.debug( "imageFile.getResizedDOM: " );
                          debug.appendChild( DOM );
                        }, function(error){
                          luna.debug( "imageFile.getResizedDOM: " + error );
                        });
                      }

                      if(file.objectType() === "File") {
                        luna.debug( file.toJSON() )
                        if( file.getFilename() === ".DS_Store" ) {
                          file.delete().then(function(result){
                            luna.debug("deleted" + file.getFilename())
                          }, function(error){
                            luna.debug(error)
                          })
                        }
                      }

                      if(file.objectType() === "ZipFile") {
                        file.unzip({
                          to: "unzipfolder"
                        }).then(function(result){
                          luna.debug("file.unzip: " + result)
                        }, function(error){
                          luna.debug("file.unzip: " + error)
                        })

                        file.onUnzip().then(function(result){
                          luna.debug("file.onUnzip: " + result)
                        }, function(error){
                          luna.debug("file.onUnzip: " + error)
                        })
                        file.onUnzipped().then(function(result){
                          luna.debug("file.onUnzipped: " + result)
                        }, function(error){
                          luna.debug("file.onUnzipped: " + error)
                        })
                        file.onUnzipping(function(progress){
                          luna.debug("file.onUnzipping: " + progress)
                        }).then(function(result){
                          luna.debug("file.onUnzipping: " + result)
                        }, function(error){
                          luna.debug("file.onUnzipping: " + error)
                        })
                      }
                    });

                    fileCollection.share({includeSubdirectoryFiles:true}).then(function(resut){
                      luna.debug("fileCollection.share: " + resut)
                    },function(error){
                      luna.debug("fileCollection.share: " + error)
                    });

                    utility.forEvery( fileCollection.getDirectories(), function(directory){
                      //listFiles(directory)
                    });

                  }, function(error){
                    luna.debug("luna.getFileCollection: " + error)
                  });
                };

                //zip3folders
                //zip3files
                listFiles("zip3folders");

                

              });


            };

            


            return {
              init: init,
              activatePage: activatePage
            };
      })();

























 
 })( typeof window !== "undefined" ? window : this, document );

