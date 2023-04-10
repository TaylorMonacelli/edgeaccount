https://stackoverflow.com/a/72476702/1495086
https://stackoverflow.com/a/10455027/16564820

That can also be #included as youve done in your description.

Unfortunately, right now, you cannot modify the cloud_final_modules,
but only override it.

I hope to add the ability to modify config sections at some point.

There is a bit more information on this in the cloud-config doc at
https://github.com/canonical/cloud-init/tree/master/doc/examples

Alternatively, you can put files in /var/lib/cloud/scripts/per-boot
and they'll be run by the scripts-per-boot path.

