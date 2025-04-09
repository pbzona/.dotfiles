return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
              __                   __   __                  
.--.--.-----.|__|.-----.-----.    |  |_|  |--.-----.        
|  |  |__ --||  ||     |  _  |    |   _|     |  -__|        
|_____|_____||__||__|__|___  |    |____|__|__|_____|        
                       |_____|                              
                                  __                        
.----.-----.--------.-----.--.--.|  |_.-----.----.          
|  __|  _  |        |  _  |  |  ||   _|  -__|   _|          
|____|_____|__|__|__|   __|_____||____|_____|__|            
                    |__|                                    
]],
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
       keys = {
         { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
         { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
         { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
         { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
         { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = " ", key = "s", desc = "Restore Session", section = "session" },
         { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
         { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
         { icon = " ", key = "q", desc = "Quit", action = ":qa" },
       },
      },
    },
  },
}
