public class Tardis.BackupTarget : GLib.Object {
    public string id;
    public string display_name;
    public string icon_name;
    public int64 last_backup_time;

    public BackupTarget (
        string id,
        string display_name,
        string icon_name,
        int64 last_backup_time
    ) {
        this.id = id;
        this.display_name = display_name;
        this.icon_name = icon_name;
        this.last_backup_time = last_backup_time;
    }

    public BackupTarget.from_json (Json.Object obj) {
        this.id = obj.get_string_member ("id");
        this.display_name = obj.get_string_member ("display_name");
        this.icon_name = obj.get_string_member ("icon_name");
        this.last_backup_time = obj.get_int_member ("last_backup_time");
    }

    public BackupTarget.from_volume (GLib.Volume volume) {
        this.last_backup_time = 0;
        this.display_name = volume.get_drive ().get_name ();

        // Try to get icon name
        var icon = new Gtk.Image.from_gicon (volume.get_icon (), Gtk.IconSize.SMALL_TOOLBAR);
        string gicon_name;
        icon.get_icon_name (out gicon_name, null);
        if (gicon_name != null) {
            icon_name = gicon_name;
        } else {
            icon_name = "drive-removable-media";
        }

        // Try to get a unique id
        var uuid = volume.get_uuid ();
        if (uuid != null) {
            id = uuid;
        } else {
            id = display_name;
        }
    }

    public void build_json (Json.Builder builder) {
        builder.begin_object ();

        builder.set_member_name ("id");
        builder.add_string_value (id);

        builder.set_member_name ("display_name");
        builder.add_string_value (display_name);

        builder.set_member_name ("icon_name");
        builder.add_string_value (icon_name);

        builder.set_member_name ("last_backup_time");
        builder.add_int_value (last_backup_time);

        builder.end_object ();
    }

    public bool out_of_date () {
        var curtime = GLib.get_real_time ();
        return (last_backup_time == 0) ||
            (curtime - last_backup_time) > GLib.TimeSpan.DAY;
    }
}
