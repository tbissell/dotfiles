# ref
# booleans:
#  auto_fullscreen
#  bring_front_click
#  cursor_warp
#  dgroups_key_binder
#  dgroups_app_rules
#  extension_defaults
#  floating_layout
#  focus_on_window_activation
#  follow_mouse_focus

import os
import subprocess
import socket
import re
from libqtile import bar, hook, layout, widget
from libqtile.command import lazy
from libqtile.config import Click, Drag, Group, Key, Screen, ScratchPad, DropDown

def init_colors():
    return [
            [ "#1D2330", "#1D2330" ], # panel background                    # 0
            [ "#84598D", "#84598D" ], # background for current screen tab   # 1
            [ "#B1B5C8", "#81B5C8" ], # font color for group names          # 2
            [ "#645377", "#645377" ], # background color for layout widget  # 3
            [ "#000000", "#000000" ], # background for other screen tabs    # 4
            [ "#AD69AF", "#AD69AF" ], # gradiant for other screen tabs      # 5
            [ "#7B8290", "#7B8290" ], # background color for network widget # 6
            [ "#AD69AF", "#AD69AF" ], # background color for pacman widget  # 7
            [ "#357FC5", "#357FC5" ], # background color for cmus widget    # 8
            [ "#000000", "#000000" ], # background color for clock widget   # 9
            [ "#84598D", "#84598D" ], # background color for systray widget # 10
            [ "#164d78", "#164d78" ], # inactive for group box              # 11
           ]

def init_layout_theme():
    return {
            "border_width": 1,
            "margin": 4,
            "border_focus": "#4770a6",
            "padding": 10,
            }

def init_widgets_defaults():
    return dict(
            font = "Liberation Mono for Powerline",
            fontsize = 12,
            padding = 8,
            )


def init_keys(config):
# Key bindings
    mod = config['mod']
    keys = [
            # WM control
            Key([mod, 'control'], 'r',      lazy.restart()),
            Key([mod, 'control'], 'q',      lazy.shutdown()),
            Key([mod], 'r',                 lazy.spawncmd()),
            Key([mod, 'shift'], 'c',        lazy.window.kill()),

            # Applications
            Key([mod], 'Return',            lazy.spawn(config['terminal'])),
            Key([mod], 'r',                 lazy.spawn(config['launcher'])),
            Key([mod], 'f',                 lazy.spawn(config['file_manager'])),
            Key([mod, 'shift'], 'l',        lazy.spawn(config['lock'])),

            # Scratchpad
            #Key([mod], 'f',                 lazy.group['scratchpad'].dropdown_toggle("terminal")),

            Key([mod], 'Left',              lazy.screen.prev_group()),
            Key([mod], 'Right',             lazy.screen.next_group()),

            # Layout control
            Key([mod, 'control'], 'space',  lazy.window.toggle_floating()),
            Key([mod], 'k',                 lazy.layout.up()),
            Key([mod], 'j',                 lazy.layout.down()),
            Key([mod, 'shift'], 'k',        lazy.layout.shuffle_up()),
            Key([mod, 'shift'], 'j',        lazy.layout.shuffle_down()),
            Key([mod, 'shift'], 'space',    lazy.layout.flip()),
            Key([mod], 'space',             lazy.next_layout()),
            Key([mod], 'n',                 lazy.layout.normalize()),
            Key([mod], 'm',                 lazy.layout.maximize()),
            Key([mod], 'KP_Enter',          lazy.window.toggle_floating()),

            # Switch window focus to other panes
            Key([mod], 'Tab', lazy.layout.next()),
    ]

    for i in range(1, 10):
        # mod + letter of group
        keys.append(Key([mod], str(i), lazy.group[str(i)].toscreen()))

        # mod + shift + leter of group = move window to group
        #keys.append(Key([mod, 'shift'], i.name, lazy.window.togroup(i.name)))
        keys.append(Key([mod, 'shift'], str(i), lazy.window.togroup(str(i))))

    return keys

def init_mouse(mod):
    mouse = (
            Drag([mod], 'Button1', lazy.window.set_position_floating(),
                start=lazy.window.get_position()),
            Drag([mod], 'Button3', lazy.window.set_size_floating(),
                start=lazy.window.get_size()),
    )
    return mouse

groups = [
        Group('1'),
        Group('2'),
        Group('3'),
        Group('4'),
        Group('5'),
        Group('6'),
        Group('7'),
        Group('8'),
        Group('9'),
#        ScratchPad('scratchpad', [
#            DropDown('terminal', "xterm", opacity=0.8),
#
#            DropDown('qshell', "xterm -e qshell",
#                x=0.05, y=0.4, width=0.9, height=0.6, opacity=0.9, on_focus_lost_hide=True)
#            ])
]


def init_layouts():
    layouts = [
            layout.MonadTall(
                # align = 0,
                # change_ratio = 0.05 # resize_ratio
                # change_size = 20 # resize change in pixels
                # max_ratio = 0.75 # percent of the screen-space of the master pane
                # min_ratio = 0.25 # percent of the screen-space of the master pane
                # min_secondary_size = 85  # minimum size in pixel for a secondary pane
                # new_at_current = False # place new windows at the position of the active window
                **layout_theme
                ),
            #layout.MonadWide(
            #    # change_ratio = 0.05 # resize_ratio
            #    # change_size = 20 # resize change in pixels
            #    # max_ratio = 0.75 # percent of the screen-space of the master pane
            #    # min_ratio = 0.25 # percent of the screen-space of the master pane
            #    # min_secondary_size = 85  # minimum size in pixel for a secondary pane
            #    # new_at_current = False # place new windows at the position of the active window
            #    **layout_theme
            #    ),
            #layout.Bsp(
            #    # fair = True # New clients are inserted in the shortest branch
            #    # grow_amount = 10 # Amount by which to grow a window/column
            #    # lower_right = True # New client occupies lower or right subspace
            #    # ratio = 1.6 # width/height ratio that dfines the partition direction
            #    **layout_theme
            #    ),
            layout.Max(),
            #layout.Stack(num_stacks=2, **layout_theme),
            layout.Tile(**layout_theme),
            #layout.RatioTile(
            #    # fancy = False # use a different mehtod to calculate window sizes
            #    # ratio = 1.618
            #    # ratio_increment = 0.1
            #    **layout_theme
            #    ),
            #layout.Matrix(**layout_theme),
            # layout.Column(
            #    border_focus_stack = '#881111'
            #    border_normal_stack = '#220000'
            #    fair = False
            #    grow_amount = 10
            #    insert_position = 0
            #    num_columns = 2
            #    split = True
            #    **layout_theme
            #    )
            #layout.TreeTab(
                # active_bg = '000080', # background color of active tab
                # active_fg = 'ffffff', # foreground color of active tab
                # border_width = 2, # width of the border
                # font = 'sans' # font
                # fontshadow = None, # font shadow color
                # fontsize = 14,
                # inactive_bg = '606060',
                # inactive_fg = 'ffffff',
                # level_shift = 8,  # shift for children tabs
                # margin_left = 6,  # left margin of the tab panel
                # margin_y = 6,  # vertical margin of the tab panel
                # padding_left = 6,  # left padding for tabs
                # padding_x = 6,  # left padding for tab label
                # padding_y = 2,  # top padding for tab label
                # panel_width = 150,  # width of the left panel
                # previous_on_rm = False,
                # section_bottom = 6,  # bottom margin of section
                # section_fg = 'ffffff',  # color of section label
                # section_fontsize = 11,
                # section_left = 4,  # left margin of section label
                # section_padding = 4,  # bottom of margin section label
                # section_top = 4,  # top margin of section label
                # sections = ['Default'],  # forground color of inactive tab
                # vspace = 2,  # space between tabs
            #    **layout_theme
            #    )
            ]

    return layouts

def init_floating_layout():
    return layout.Floating(
            # auto_float_types = {'splash', 'utility', 'toolbar', 'dialog', 'notification'}
            **layout_theme
            )

def init_widgets():
    return [
        widget.GroupBox(
            font='Hack Bold',
            highlight_method='block',
            active=colors[2],
            inactive=colors[11],
            padding=0,
        ),
        widget.Prompt(),
        #widget.WindowName(),
        widget.Spacer(),
        widget.Systray(),
        widget.Volume(foreground=colors[2]),
        widget.Sep(background=colors[0], padding=2),
        widget.Memory(foreground=colors[2]),
        widget.Sep(background=colors[0], padding=2),
        widget.Clock(foreground=colors[2], format='%a %d %b %I:%M %p'),
        widget.CurrentLayoutIcon(foreground=colors[2]),
    ]


def init_screens(widgets):
    return [
        Screen(
            top=bar.Bar(
                widgets=widgets,
                size=20,
                background=colors[0],
            ),
        ),
    ]

if __name__ in ["config", "__main__"]:
    wmname = 'qtile'
    mod = 'mod4'
    custom_terminal = 'xfce4-terminal'
    config = dict(
            mod = 'mod4',
            terminal = 'xfce4-terminal',
            launcher = 'rofi -show',
            file_manager = 'xfce4-terminal -e vifm',
            lock = '/home/tbissell/.config/custom/lock.sh'
            )

    bring_front_click = True
    cursor_warp = False
    follow_mouse_focus = True
    auto_fullscreen = True

    dgroupds_key_binder = None
    dgroups_app_rules = []

    colors = init_colors()
    keys = init_keys(config)
    mouse = init_mouse(mod)

    layout_theme = init_layout_theme()
    layouts = init_layouts()
    floating_layout = layout.Floating()
    border_args = {"border_width": 2}

    widget_defaults = init_widgets_defaults()
    screens = init_screens(init_widgets())

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])
