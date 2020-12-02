--[[

Touch screen designer.

Simple WYSIWYG editor for touch screens.
Can export configuration through digiline
or through touch screen multi line text field.

Author: SX

--]]

local GRID_SIZE = mem.GRID_SIZE and mem.GRID_SIZE or 0.4

local initialize_designer = function()

  mem.ALLOW_RESIZE_W = {
    addfield = 1,
    addpwdfield = 1,
    addbutton = 1,
    addimage_button = 1,
    addtextarea = 1,
    addtextlist = 1,
    adddropdown = 1,
    addimage = 1,
  }
  mem.ALLOW_RESIZE_H = {
    addimage_button = 1,
    addtextarea = 1,
    addtextlist = 1,
    addimage = 1,
  }
  mem.SELECTABLE_COMPONENTS = {
    button = 1,
    buttonexit = 1,
    imagebutton = 1,
    imagebuttonexit = 1,
  }
  mem.WORKSPACE_CONTROL = {
    command = 'addimage_button',
    image = 'signs_road_red.png',
    name = '_ctrl',
    type = 'ctrl',
    label = '.',
    W = 0.4,
    H = 0.4,
  }
  mem.CTRL_OFFSET = {
    addfield = {
      X = -0.3,
      Y = -0.4,
    },
    addpwdfield = {
      X = -0.3,
      Y = -0.4,
    },
  }
  mem.COMPONENT_DEFAULTS = {
    button = {
      command = 'addbutton',
      name = '_button_',
      label = 'untitled',
      X = 0.8,
      Y = 0.8,
      W = 1.6,
      H = 0.8,
    },
    buttonexit = {
      variant = '_exit',
      command = 'addbutton',
      name = '_buttonexit_',
      label = 'untitled',
      X = 0.8,
      Y = 0.8,
      W = 1.6,
      H = 0.8,
    },
    imagebutton = {
      command = 'addimage_button',
      name = "_imagebutton_",
      label = "untitled",
      image = 'wool_yellow.png',
      X = 0.8,
      Y = 0.8,
      W = 1.6,
      H = 0.8,
    },
    imagebuttonexit = {
      variant = '_exit',
      command = 'addimage_button',
      name = "_imagebuttonexit_",
      label = "untitled",
      image = 'wool_yellow.png',
      X = 0.8,
      Y = 0.8,
      W = 1.6,
      H = 0.8,
    },
    field = {
      command = 'addfield',
      name = '_field_',
      label = 'untitled',
      default = 'value',
      X = 0.7,
      Y = 0.7,
      W = 1.6,
      H = 0.8,
    },
    pwdfield = {
      command = 'addpwdfield',
      name = '_pwdfield_',
      label = 'untitled',
      X = 0.7,
      Y = 0.7,
      W = 1.6,
      H = 0.8,
    },
    label = {
      command = 'addlabel',
      label = 'untitled',
      name = '_label_', -- Deleted on export, required for editor
      X = 0.7,
      Y = 0.7,
      W = 1.2, -- Deleted on export, required for editor
      H = 0.8, -- Deleted on export, required for editor
    },
    vertlabel = {
      command = 'addvertlabel',
      label = 'untitled',
      name = '_vertlabel_', -- Deleted on export, required for editor
      X = 0.8,
      Y = 0.8,
      W = 0.8, -- Deleted on export, required for editor
      H = 1.2, -- Deleted on export, required for editor
    },
    textarea = {
      command = "addtextarea",
      label = "untitled",
      name = "_textarea_",
      default = 'value',
      X = 0.8,
      Y = 0.8,
      W = 2.6,
      H = 1.8,
    },
    textlist = {
      command = "addtextlist",
      label = "untitled",
      name = "_textlist_",
      listelements = {},
      transparent = false,
      selected_id = 1,
      X = 0.8,
      Y = 0.8,
      W = 2.6,
      H = 1.8,
    },
    dropdown = {
      command = "adddropdown",
      label = "untitled",
      name = "_dropdown_",
      choices = {},
      selected_id = 1,
      X = 0.8,
      Y = 0.8,
      W = 1.6,
      H = 0.8,
    },
  }
  mem.COMPONENT_TYPES = {}
  for k,_ in pairs(mem.COMPONENT_DEFAULTS) do
    table.insert(mem.COMPONENT_TYPES, k)
  end
end

local ALLOW_RESIZE_W = mem.ALLOW_RESIZE_W
local ALLOW_RESIZE_H = mem.ALLOW_RESIZE_H
local SELECTABLE_COMPONENTS = mem.SELECTABLE_COMPONENTS
local WORKSPACE_CONTROL = mem.WORKSPACE_CONTROL
local CTRL_OFFSET = mem.CTRL_OFFSET
local COMPONENT_DEFAULTS = mem.COMPONENT_DEFAULTS
local COMPONENT_TYPES = mem.COMPONENT_TYPES

local draw_designer = function()
  local ui = {
    {
      command = "addbutton_exit",  X=9.6, Y=-0.31, W=0.7, H=0.7,
      name = "quit", label = "X"
    },
  }

  if mem.draw_code then
    digiline_send("touch", mem.touch_clear_commands)
    table.insert(ui, {
      command = "addbutton",  X=9.5, Y=0.49, W=0.8, H=0.8,
      name = "close_code", label = "[[>"
    })
    table.insert(ui, {
      command = "addtextarea", X=0.5, Y=0.5, W=9, H=8.5,
      name = "result", label = "Generated Touch Screen configuration code", default = mem.code
    })
  else
    table.insert(ui, {
      command = "addbutton",  X=mem.draw_toolbar and 9.45 or 9.65, Y=0.5, W=mem.draw_toolbar and 0.85 or 0.65, H=0.8,
      name = "hide_toolbar", label = mem.draw_toolbar and "[[>" or "<]]"
    })
    if not mem.draw_component_editor and mem.draw_workspace then
      digiline_send("touch", mem.workspace)
    else
      digiline_send("touch", { command = "clear" })
    end
    if mem.draw_toolbar then
      -- Static toolbar components
      digiline_send("touch", mem.toolbar)
      -- Dynamic toolbar components
      digiline_send("touch", {
        {
          command = "addbutton",  X=8.45, Y=0.5, W=0.7, H=0.8,
          name = "toggle_grid_size", label = string.format('%.1f', GRID_SIZE)
        },{
          command = "addbutton",  X=8.95, Y=1.2, W=0.7, H=0.8,
          name = 'toggle_size_move', label = (mem.mode_move and 'move' or 'size')
        },{
          command = "addbutton",  X=8.45, Y=1.9, W=0.7, H=0.8,
          name = "edit_component", label = "edit"
        },{
          command = "addlabel",  X=8.6, Y=3.3,
          label = mem.selected.ref and string.format('X:%.1f Y:%.1f\nW:%.1f H:%.1f', mem.selected.ref.X, mem.selected.ref.Y, mem.selected.ref.W, mem.selected.ref.H) or 'No selection'
        },{
          command = "addfield",  X=8.75, Y=4.75, W=1.7, H=0.6,
          name = 'component_name', label = 'Ref. key:',
          default = mem.selected.display_name and mem.selected.display_name or ''
        }
      })
      --[[
      for _,v in pairs(mem.toolbar) do
        table.insert(ui, v)
      end
      table.insert(ui, {
        command = "addfield",  X=8.6, Y=4.9, W=1.7, H=0.6,
        name = 'component_name', label = 'Ref. key:',
        default = mem.selected.display_name and mem.selected.display_name or ''
      })
      --]]
    end
    if mem.draw_component_editor then
      local editor_ui= {
        {
          command = 'addimage_button',
          image = 'wool_red.png', X=2.5, Y=4.5, W=2, H=0.8,
          name = "edit_component", label = "Cancel"
        },{
          command = 'addimage_button',
          image = 'wool_green.png', X=4.6, Y=4.5, W=2, H=0.8,
          name = 'component_editor_save', label = 'Save'
        },
      }
      local input_y = 3.8
      if mem.selected.ref.label then
        table.insert(editor_ui, {
          command = "addfield",  X=2.8, Y=input_y, W=4, H=0.8,
          name = 'component_label', label = 'Component label:',
          default = mem.selected.ref.label
        })
        input_y = input_y - 1
      end
      if mem.selected.ref.default then
        table.insert(editor_ui, {
          command = "addfield",  X=2.8, Y=input_y, W=4, H=0.8,
          name = 'component_default', label = 'Default value:',
          default = mem.selected.ref.default
        })
        input_y = input_y - 1
      end
      if mem.selected.ref.image then
        table.insert(editor_ui, {
          command = "addfield",  X=2.8, Y=input_y, W=4, H=0.8,
          name = 'component_image', label = 'Image:',
          default = mem.selected.ref.image
        })
        input_y = input_y - 1
      end
      if mem.selected.ref.choices or mem.selected.ref.listelements then
        table.insert(editor_ui, {
          command = "addfield",  X=2.8, Y=input_y, W=2.6, H=0.8,
          name = 'component_listelement', label = 'New entry:',
          default = ''
        })
        table.insert(editor_ui, {
          command = "addbutton",  X=5.2, Y=input_y - 0.3, W=0.8, H=0.8,
          name = "component_listelement_add", label = 'Add'
        })
        table.insert(editor_ui, {
          command = "addbutton",  X=6, Y=input_y - 0.3, W=0.8, H=0.8,
          name = "component_listelement_del", label = 'Del'
        })
        input_y = input_y - 2.6
        table.insert(editor_ui, {
          command = "addtextlist", X = 2.5, Y = input_y, W = 4, H = 2,
          label = "Item editor:",
          name = "component_editor_items",
          listelements = mem.selected.ref.choices or mem.selected.ref.listelements,
          selected_id = mem.component_editor_items_idx or 1,
        })
        input_y = input_y - 1
      end
      digiline_send("touch", editor_ui)
    end
  end
  digiline_send("touch", ui)
end

local reset = function()
  mem.component_index = {}
  for k,_ in pairs(COMPONENT_DEFAULTS) do
    mem.component_index[k] = 0
  end
  mem.workspace = {
    { command = "clear" } -- 'clear' command is special case and not indexed in workspace
  }
  mem.workspace_search = {}
  mem.workspace_control = {}
  mem.draw_workspace = true
  mem.draw_toolbar = true
  mem.draw_code = false
  mem.mode_move = true
  mem.locked = false
  mem.code = ''
  mem.selected = {
    display_name = nil,
    ref = nil,
    ctrl = nil
  }
  -- Add only static controls here, keeping cached in memory reduces table constructors
  mem.toolbar = {
    {
      command = "addbutton",  X=8.95, Y=0.5, W=0.7, H=0.8,
      name = "up", label = "^"
    },{
      command = "addbutton",  X=8.45, Y=1.2, W=0.7, H=0.8,
      name = "left", label = "<"
    },{
      command = "addbutton",  X=9.45, Y=1.2, W=0.7, H=0.8,
      name = "right", label = ">"
    },{
      command = "addbutton",  X=8.95, Y=1.9, W=0.7, H=0.8,
      name = "down", label = "v"
    },{
      command = "addbutton",  X=9.45, Y=1.9, W=0.7, H=0.8,
      name = "delete", label = "del"
    },{
      command = "addbutton",  X=8.45, Y=2.6, W=1.7, H=0.8,
      name = "reset", label = "Reset"
    },{
      command = "addtextlist", X=8.45, Y=5.1, W=1.48, H=1.8,
      name="component_type",  selected_id=1, listelements = COMPONENT_TYPES
    },{
      command = "addbutton",  X=8.45, Y=6.9, W=1.7, H=0.8,
      name = "create", label = "Create"
    },{
      command = "addbutton",  X=8.45, Y=7.6, W=1.7, H=0.8,
      name = "code", label = "Generate"
    },
  }
  mem.component_type_id = 1
end

local info = function(msg)
  digiline_send('lcd', msg)
end

local validate_component_name = function(name)
  return type(name) == 'string' and #name > 0
end

local indexof = function(items, value)
  for k,v in pairs(items) do
    if v == value then
      return k
    end
  end
  return nil
end

local textlist_indexof = function(value)
  if #value >= 5 and string.sub(value, 1, 4) == 'CHG:' then
    return tonumber(string.sub(value, 5, #value))
  end
  return nil
end

local update_control_position = function(control, component)
  if control then
    if CTRL_OFFSET[component.command] then
      control.X = component.X + CTRL_OFFSET[component.command].X
      control.Y = component.Y + CTRL_OFFSET[component.command].Y
    else
      control.X = component.X
      control.Y = component.Y
    end
  end
end

local get_next_unused_name = function(component_type, name)
  local i = 0
  local result = name
  local prefix = COMPONENT_DEFAULTS[component_type].name
  while mem.workspace_search[prefix .. result] do
    -- add numbers until free unused name is found
    i = i + 1
    result = name .. '_' .. i
  end
  return result
end

local create_component_name = function(component_type, name)
  if not COMPONENT_DEFAULTS[component_type] then
    return false
  end
  if validate_component_name(name) then
    -- attempt to use supplied component name
    return get_next_unused_name(component_type, name)
  else
    -- generate new component name
    mem.component_index[component_type] = mem.component_index[component_type] + 1
    return get_next_unused_name(component_type, component_type .. mem.component_index[component_type])
  end
end

local create_component = function(component_type, name)
  local result = {}
  for k,v in pairs(COMPONENT_DEFAULTS[component_type]) do
    if type(v) == 'table' then
      result[k] = {'value'} -- Avoid references to default component values
    else
      result[k] = v
    end
  end
  result.type = component_type
  if result.name then
    result.name = result.name .. name
  end
  return result
end

local create_control_component = function(component)
  local result = {}
  for k,v in pairs(WORKSPACE_CONTROL) do
    result[k] = v
  end
  result.name = result.name .. component.name
  update_control_position(result, component)
  return result
end

local move_component = function(selection, X, Y)
  if selection.ref then
    if X ~= nil and selection.ref.X + X >= 0 and selection.ref.X + selection.ref.W + X <= 10 then
      selection.ref.X = selection.ref.X + X
    end
    if Y ~= nil and selection.ref.Y + Y >= 0 and selection.ref.Y + selection.ref.H + Y <= 8 then
      selection.ref.Y = selection.ref.Y + Y
    end
    update_control_position(selection.ctrl, selection.ref)
  end
end

local resize_component = function(selection, W, H)
  if not selection.ref then
    return false
  end
  local enable_W = ALLOW_RESIZE_W[selection.ref.command] and true or false
  local enable_H = ALLOW_RESIZE_H[selection.ref.command] and true or false
  if selection.ref.W and selection.ref.H then
    if enable_W and W ~= nil and selection.ref.W >= GRID_SIZE and selection.ref.W <= 10 then
      selection.ref.W = selection.ref.W + W
    end
    if enable_H and H ~= nil and selection.ref.H >= GRID_SIZE and selection.ref.H <= 10 then
      selection.ref.H = selection.ref.H + H
    end
  else
    return false
  end
  return true
end

local nice_name = function(name)
  local name_idx = string.find(name, "_", 2, true)
  return string.sub(name, name_idx + 1, #name)
end

local deselect = function()
  mem.selected.ref = nil
  mem.selected.ctrl = nil
  mem.selected.display_name = nil
  mem.draw_component_editor = false
  mem.component_editor_items_idx = nil
end

local select_component = function(name)
  if mem.workspace_search[name] then
    mem.selected.ref = mem.workspace[mem.workspace_search[name]]
    mem.selected.ctrl = nil
    mem.selected.display_name = nice_name(name)
    return true
  elseif mem.workspace_control[name] then
    local main_name_idx = string.find(name, "_", #WORKSPACE_CONTROL.name + 1, true)
    local main_name = string.sub(name, main_name_idx, #name)
    mem.selected.ctrl = mem.workspace[mem.workspace_control[name]]
    mem.selected.ref = mem.workspace[mem.workspace_search[main_name]]
    mem.selected.display_name = nice_name(main_name)
    return true
  end
  deselect()
  return false
end

local workspace_cleanup = function()
  mem.workspace_search = {}
  mem.workspace_control = {}
  workspace = {{command='clear'}}
  for index,component in pairs(mem.workspace) do
    if component and component.name and component.type ~= 'ctrl' then
      table.insert(workspace, component)
      mem.workspace_search[component.name] = table.maxn(workspace)
      if not SELECTABLE_COMPONENTS[component.type] then
        -- Add control anchor button to allow passive component selection
        local control = create_control_component(component)
        table.insert(workspace, control)
        mem.workspace_control[control.name] = table.maxn(workspace)
      end
    end
  end
  mem.workspace = workspace
end

local functions = {
  up = function()
    if mem.mode_move then
      move_component(mem.selected, nil, -GRID_SIZE)
    else
      resize_component(mem.selected, nil, GRID_SIZE)
    end
  end,
  down = function()
    if mem.mode_move then
      move_component(mem.selected, nil, GRID_SIZE)
    else
      resize_component(mem.selected, nil, -GRID_SIZE)
    end
  end,
  left = function()
    if mem.mode_move then
      move_component(mem.selected, -GRID_SIZE, nil)
    else
      resize_component(mem.selected, -GRID_SIZE, nil)
    end
  end,
  right = function()
    if mem.mode_move then
      move_component(mem.selected, GRID_SIZE, nil)
    else
      resize_component(mem.selected, GRID_SIZE, nil)
    end
  end,
  toggle_size_move = function()
    mem.mode_move = not mem.mode_move
  end,
  toggle_grid_size = function()
    GRID_SIZE = GRID_SIZE < 1.6 and GRID_SIZE + 0.4 or 0.4
    mem.GRID_SIZE = GRID_SIZE
  end,
  delete = function()
    if mem.selected.ref then
      local name = mem.selected.ref.name
      local id = mem.workspace_search[name]
      mem.workspace[id] = nil
      workspace_cleanup()
      deselect()
    end
  end,
  component_type = function(data)
    local component_type_idx = textlist_indexof(data.component_type)
    mem.component_type = COMPONENT_TYPES[component_type_idx]
    mem.toolbar[7].selected_id = component_type_idx
  end,
  create = function(data)
    local name = create_component_name(mem.component_type, data.component_name)
    if name then
      local component = create_component(mem.component_type, name)
      table.insert(mem.workspace, component)
      mem.workspace_search[component.name] = table.maxn(mem.workspace)
      if not SELECTABLE_COMPONENTS[mem.component_type] then
        -- Add control anchor button to allow passive component selection
        local control = create_control_component(component)
        table.insert(mem.workspace, control)
        mem.workspace_control[control.name] = table.maxn(mem.workspace)
      end
      select_component(name)
    end
  end,
  hide_toolbar = function()
    mem.draw_toolbar = not mem.draw_toolbar
  end,
  edit_component = function()
    mem.component_editor_items_idx = 1
    mem.draw_component_editor = not mem.draw_component_editor
  end,
  component_editor_items = function(data)
    mem.component_editor_items_idx = textlist_indexof(data.component_editor_items)
  end,
  component_listelement_add = function(data)
    if mem.selected.ref then
      local items = mem.selected.ref.choices or mem.selected.ref.listelements
      if mem.component_editor_items_idx then
        table.insert(items, mem.component_editor_items_idx + 1, data.component_listelement)
        mem.component_editor_items_idx = mem.component_editor_items_idx + 1
      elseif items then
        table.insert(items, data.component_listelement)
      end
    else
      mem.draw_component_editor = false
      deselect()
    end
  end,
  component_listelement_del = function(data)
    if mem.selected.ref then
      local items = mem.selected.ref.choices or mem.selected.ref.listelements
      if items and mem.component_editor_items_idx then
        table.remove(items, mem.component_editor_items_idx)
        mem.component_editor_items_idx = math.max(1, mem.component_editor_items_idx - 1)
      end
    else
      mem.draw_component_editor = false
      deselect()
    end
  end,
  component_editor_save = function(data)
    if mem.selected.ref then
      if data.component_label then
        mem.selected.ref.label = data.component_label
      end
      if data.component_default then
        mem.selected.ref.default = data.component_default
      end
      if data.component_image then
        mem.selected.ref.image = data.component_image
      end
    end
    mem.draw_component_editor = false
    deselect()
  end,
  lock = function()
    -- toggle lock, maybe add timeout for lock in public version?
    mem.locked = not mem.locked
  end,
  reset = function()
    -- add confirmation message before destroying everything?
    reset()
  end,
  code = function()
    local result = {}
    local vk = { [true] = '="', [false] = '=', }
    local vi = { [true] = '"', [false] = '', }
    local ve = { [true] = '",\n', [false] = ',\n', }
    local labelcleanup = { name = 1, H = 1, W = 1 }
    local indent = 2
    table.insert(result, 'digiline_send("touch",{\n')
    for i,component in ipairs(mem.workspace) do
      if mem.workspace_control[component.name] ~= i then
        local islabel = component.command == 'addlabel' or component.command == 'addvertlabel'
        table.insert(result, (i == 1 and string.rep(' ', indent) or '') .. '{\n')
        indent = indent + 2
        local pre = string.rep(' ', indent)
        local pos = {}
        for k,v in pairs(component) do
          if type(v) == 'table' then
            digiline_send('dbg', 'serializing table ' .. k)
            table.insert(result, string.rep(' ', indent) .. k .. '={\n')
            indent = indent + 2
            pre = string.rep(' ', indent)
            for _,li in ipairs(v) do
              local quote = type(li) == 'string'
              table.insert(result, pre .. vi[quote] .. li .. ve[quote])
            end
            indent = indent - 2
            table.insert(result, string.rep(' ', indent) .. '},')
          elseif k ~= 'type' then
            if k == 'X' or k == 'Y' or k == 'H' or k == 'W' then
              table.insert(pos, k .. '=' .. v .. ',')
            else
              local quote = type(v) == 'string'
              if islabel and labelcleanup[k] then
                -- noop
              elseif k == 'name' then
                table.insert(result, pre .. k .. vk[quote] .. nice_name(v) .. ve[quote])
              else
                table.insert(result, pre .. k .. vk[quote] .. tostring(v) .. ve[quote])
              end
            end
          end
        end
        if table.maxn(pos) > 0 then
          table.insert(result, pre .. table.concat(pos, ' ') .. '\n')
        end
        indent = indent - 2
        table.insert(result, string.rep(' ', indent) .. '},')
      end
    end
    table.insert(result, '{X=7.18,label="Created with SX Digi labs Touch Designer",Y=8.11,command="addlabel"}\n})\n')
    mem.code = table.concat(result)
    mem.draw_code = true
  end,
  close_code = function()
    mem.draw_code = false
  end,
  quit = function()
    deselect()
  end,
}

local selectable = function(key)
  -- Hack to get around the fact that touch screen will always populate input fields into incoming data
  -- FIXME somehow, maybe find match from table?
  local m = string.sub(key, 1, 2)
  return m == '_b' or m == '_c' or m == '_i'
end

local execute_event = function(data)
  for key,_ in pairs(data) do
    if selectable(key) then
      select_component(key)
      return true
    elseif functions[key] then
      functions[key](data)
      return true
    end
  end
  return false
end

if event.type == 'digiline' then
  if not execute_event(event.msg) then
    local str = ''
    for k,v in pairs(event.msg) do
      str = str .. k
    end
    info('Exec failed' .. str)
  end
elseif event.type == 'program' then
  mem.touch_clear_commands = { command = "clear" }
elseif event.type == 'interrupt' then
  if not mem.workspace then
    reset()
  end
end

if COMPONENT_TYPES then
  draw_designer()
else
  initialize_designer()
  interrupt(1)
end
