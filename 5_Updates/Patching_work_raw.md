# Raw patching work

This is just a reminder of how I was working with quilt given our build system. It's kinda of annoying but makes everything simple to build. 

This is just docs for myself and will likely be removed before 5.0 release. 

```
ls
quilt 
quilt patches
quilt patches ls
quilt refresh
quilt --version
cd build_dir/
ls
quilt 
quilt push
quilt push -a
quilt refresh
quilt push -a
ls package/network/services/uhttpd/files/uhttpd.init 
quilt refresh
quilt push -a
quilt diff package/network/services/uhttpd/files/uhttpd.init
quilt push -a
ls
vi patches/packages/0073-Rebrand-uhttpd-cert-Opuntia.patch 
vi package/network/services/uhttpd/files/uhttpd.init
quilt edit package/network/services/uhttpd/files/uhttpd.init
quilt diff
quilt refresh
quilt push -a
cp patches/packages/0062-Set-root-password.patch ../patches/packages/0062-Set-root-password.patch 
quilt diff
quilt refresh
quilt 
quilt revert --help
quilt revert build_dir/package/network/services/uhttpd/files/uhttpd.init
quilt series
vi package/network/services/uhttpd/files/uhttpd.init
quilt refresh
quilt series
quilt ?
quilt files
cd ..
make dist_clean
make distclean
make ev1000 
cd build_dir/
quilt serias
quilt series
quilt push 0014-Update-openvpn-init-script.patch
quilt push patches/packages/0014-Update-openvpn-init-script.patch
quilt refresh patches/packages/0014-Update-openvpn-init-script.patch
cp patches/packages/0014-Update-openvpn-init-script.patch ../patches/packages/0014-Update-openvpn-init-script.patch 
quilt series
quilt push 
quilt series
quilt push 
quilt series
quilt push 
quilt series
quilt push 
quilt series
quilt refresh patches/packages/0073-Rebrand-uhttpd-cert-Opuntia.patch 
quilt refresh patches/packages/0062-Set-root-password.patch 
quilt 
quilt e
quilt push -f 
quilt series
quilt refresh patches/packages/0073-Rebrand-uhttpd-cert-Opuntia.patch
cp patches/packages/0073-Rebrand-uhttpd-cert-Opuntia.patch ../patches/packages/0073-Rebrand-uhttpd-cert-Opuntia.patch
quilt push 
quilt series
```