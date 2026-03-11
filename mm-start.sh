#!/bin/sh
set -e
mkdir -p /paperclip/instances/default/data/storage
node -e "
var fs=require('fs');
var cfg={
  database:{mode:'postgres',connectionString:process.env.DATABASE_URL},
  server:{host:'0.0.0.0',port:3100,serveUi:true,deploymentMode:'authenticated',exposure:'private'},
  auth:{baseUrlMode:'env',disableSignUp:false},
  logging:{mode:'stdout'},
  storage:{provider:'local_disk',localDisk:{baseDir:'/paperclip/instances/default/data/storage'}}
};
fs.writeFileSync('/paperclip/instances/default/config.json',JSON.stringify(cfg));
console.log('Config written to /paperclip/instances/default/config.json');
"
exec paperclipai run
