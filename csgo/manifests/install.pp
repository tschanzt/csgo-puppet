class csgo::install (
	$srcds_path 	= $::csgo::srcds_path,
	$map 		= $::csgo::map,
	$game_type	= $::csgo::game_type,
	$game_mode	= $::csgo::game_mode,
	$mapgroup	= $::csgo::mapgroup,
    $game_directory = "/home/eevent/csgo/serverfiles",
    $base_dir = "/home/eevent/csgo"

	) {
    archive { 'cfg':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/cfg",
        ensure => present,
        url => 'https://gfx.esl.eu/media/counterstrike/csgo/downloads/configs/csgo_esl_serverconfig.zip',
        src_target => '/tmp',
	extension => 'zip'
    }
    exec {'mv csgo/cfg/csgo_esl_serverconfig/* csgo/cfg/':
	path => '/usr/bin:/usr/sbin:/bin',
	cwd => $game_directory,
	user => 'eevent',
	require => Archive['cfg']
   }
    archive { 'metamod':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'sm':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6454-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'get5':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo",
        ensure => present,
        url => 'https://github.com/splewis/get5/releases/download/0.7.1/get5_0.7.1.zip',
        follow_redirects => true,
        src_target => '/tmp',
        extension => 'zip'
    }

    file {"${game_directory}/csgo/cfg/server.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/server.cfg',
        owner => 'eevent',
        group => 'eevent'
        }

    file {"${game_directory}/csgo/cfg/autoexec.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/autoexec.cfg',
        owner => 'eevent',
        group => 'eevent'
    }

    file {"${game_directory}/set_prio.sh":
    	replace => true,
    	source => 'puppet:///modules/csgo/set_prio.sh',
    	owner => 'eevent',
    	group => 'eevent',
    	mode => '774'
    }
    file {"${base_dir}/lgsm/config-lgsm/csgoserver/common.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/common.cfg',
        owner => 'eevent',
        group => 'eevent',
        mode => '774'
    }

    file {"${game_directory}/csgo/cfg/get5/live.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/live.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/addons/sourcemod/cfg/get5.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/get5.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/bo1.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/bo1.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/bo3.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/bo3.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    $codefile = $::hostname?{
    'eevent1'=> file('csgo/eevent-csgo-1.txt'),
    'eevent2'=> file('csgo/eevent-csgo-2.txt'),
    'eevent3'=> file('csgo/eevent-csgo-3.txt'),
    'eevent4'=> file('csgo/eevent-csgo-4.txt'),
    'eevent5'=> file('csgo/eevent-csgo-5.txt'),
    'eevent6'=> file('csgo/eevent-csgo-6.txt'),
}
    $codes = $codefile.split('\n')

    $bla = [0,1,2,3,4,5,6,7]
    each($bla) |$instance| {
        $gameport = 27015 + (100*$instance)
        $tvport = 27020 + (100*$instance)
        $clport = 27005 + (100*$instance)
        $token = $codes[$instance]
        $host = $::hostname
        if $instance == 0 {
            $fname = 'csgoserver.cfg'
        }
        else {
            $number = ($instance+1)
            $fname = "csgoserver-${number}.cfg"
        }
        file {"${base_dir}/lgsm/config-lgsm/csgoserver/${fname}":
            content => template('csgo/csgoserver.cfg.erb'),
            owner => eevent,
            group => eevent,
            mode => '774',
        }

        file {"${game_directory}/csgo/cfg/${fname}":
            content => template('csgo/csgoserver_csgo.cfg.erb'),
            owner => eevent,
            group => eevent,
            replace => true,
        }
    }
}
