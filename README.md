Fireworks Extensions
===================

A fairly comprehensive dump of source files for all [Fireworks extensions](http://www.senocular.com/fireworks/extensions/) available at [senocular.com](http://senocular.com).

Caveats
-------

* Some source files may be older than the posted extensions
* A complete set of source files may not be available for every extension (particularly when it comes to graphics used within some panels)
* There may be some extensions whose source files have been forever lost :sob:
* The code was not written to be released so it could be quite messy


File Types
----------

Information on some of the file types you'll see in this repo:

* **.MXI**: *Macromedia Extension Information*, metadata used to generate installers for the Adobe (was Macromedia) Extension manager.  These files are useful to know what files pertain to a certain extension as more than one may be referenced. Paths referenced within these files may not match the file paths within this repo.
* **.JSF**: *JavaScript for Fireworks*, containing JavaScript code that calls Fireworks APIs to perform the actions of the extension. Note that some extension code may be contained within a FLA file rather than be accessible as a separate JSF.
* **.FLA (.SWF)** *Flash source (fla) and executables (swf)*, used for panel and dialog UI for Fireworks extensions.

