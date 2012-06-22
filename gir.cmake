set(static_gir_sources
        "gir/DBus-1.0.gir"
        "gir/DBusGLib-1.0.gir"
        "gir/fontconfig-2.0.gir"
        "gir/freetype2-2.0.gir"
        "gir/GL-1.0.gir"
        "gir/libxml2-2.0.gir"
        "gir/xft-2.0.gir"
        "gir/xlib-2.0.gir"
        "gir/xfixes-4.0.gir"
        "gir/xrandr-1.3.gir"
		)
		
target_add_gir(static_gir "gir/" ${static_gir_sources})