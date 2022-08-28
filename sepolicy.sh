# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"

# context
magiskpolicy --live "type vendor_file"
magiskpolicy --live "type vendor_configs_file"
magiskpolicy --live "dontaudit { vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "allow     { vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "dontaudit init { vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "allow     init { vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "dontaudit init { vendor_file vendor_configs_file } file relabelfrom"
magiskpolicy --live "allow     init { vendor_file vendor_configs_file } file relabelfrom"

# sock_file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } property_socket sock_file write"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } property_socket sock_file write"

# unix_stream_socket
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } init unix_stream_socket connectto"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } init unix_stream_socket connectto"

# property_service
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } default_prop property_service set"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } default_prop property_service set"

# additional
magiskpolicy --live "allow { hal_audio_default mtk_hal_audio audioserver } system_suspend_hwservice hwservice_manager find"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { default_prop boottime_prop } file { read open getattr map }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { default_prop boottime_prop } file { read open getattr map }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { mnt_vendor_file system_prop } file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { mnt_vendor_file system_prop } file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } audio_prop file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } audio_prop file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } vendor_default_prop file open"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } vendor_default_prop file open"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } sysfs_net dir read"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } sysfs_net dir read"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "dontaudit hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "allow     hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "dontaudit mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "allow     mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "dontaudit audioserver audioserver capability2 block_suspend"
magiskpolicy --live "allow     audioserver audioserver capability2 block_suspend"


