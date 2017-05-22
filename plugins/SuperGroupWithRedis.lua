--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super_deleted(cb_extra, success, result)
local receiver = cb_extra.receiver
 local msg = cb_extra.msg
  local deleted = 0 
if success == 0 then
send_large_msg(receiver, "") 
end
for k,v in pairs(result) do
  if not v.first_name and not v.last_name then
deleted = deleted + 1
 kick_user(v.peer_id,msg.to.id)
 end
 end
--send_large_msg(receiver, "♨️ <b>"..deleted.." </b>دلیت اکانت از گروه اخراج شد !") 
  reply_msg(msg.id, "♨️ <b>"..deleted.." </b>دلیت اکانت از گروه اخراج شد !", ok_cb, false)	
 end 

local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if type(result) == 'boolean' then
    print('This is a old message!')
    --return reply_msg(msg.id, '[Not supported] This is a old message!', ok_cb, false)
  end
  if success == 0 then
send_large_msg(receiver, "ادمینم کن حاجی") 
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  --lock_arabic = 'no',
		 -- lock_link = "yes",
                  --flood = 'yes',
		  --lock_spam = 'yes',
		  --lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  --lock_rtl = 'no',
		  --lock_tgservice = 'yes',
	          --lock_fwd = 'yes',
		  --lock_reply = 'no',			
		  --lock_contacts = 'no',
		  --strict = 'no'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      local hash1 = 'link:'..msg.to.id		
       redis:set(hash1, true)	
      local hash2 = 'spam:'..msg.to.id		
       redis:set(hash2, true)
       local hash3 = 'fwd:'..msg.to.id
        redis:set(hash3, true)
       local hash4 = 'reply:'..msg.to.id
        redis:del(hash4)
       local hash11 = 'inline:'..msg.to.id
	    redis:set(hash11, true)
       local text2 = "سودو <b>"..msg.from.first_name.." </b>گروه <code>"..msg.to.title.." </code>رو ادد کرد !"			
       send_large_msg("user#id"..250877155,text2)			
       local text = '✅ گروه <b>'..msg.to.title..' </b>به لیست گروه های تحت مدیریت ربات اضافه شد !'
       return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if type(result) == 'boolean' then
    print('This is a old message!')
    --return reply_msg(msg.id, '[Not supported] This is a old message!', ok_cb, false)
  end
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
       local text2 = "سودو <b>"..msg.from.first_name.." </b>گروه <code>"..msg.to.title.." </code>رو حذف کرد !"			
       send_large_msg("user#id"..250877155,text2)				
	local text = '🚫 گروه <b>'..msg.to.title..' </b>از لیست گروه های تحت مدیریت ربات حذف شد !'
        return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

local function promote(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = "@"..member_username
  if not data[group] then
    return 
  end
  if data[group]['moderators'][tostring(user_id)] then
    return 
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_name, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local name = member_name
  if not data[group] then
    return 
  end
  if data[group]['moderators'][tostring(user_id)] then
    return 
  end
  data[group]['moderators'][tostring(user_id)] = name
  save_data(_config.moderation.data, data)
end

local function promoteadmin(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type	
local text = "افراد زیر همگی در ربات مدیر شدند :"	
for k,v in pairsByKeys(result) do
if v.username then
   promote(cb_extra.receiver,v.username,v.peer_id)		
end
if not v.username then
   promote2(cb_extra.receiver,v.first_name,v.peer_id)		
end		
	        vname = v.first_name:gsub("‮", "")
	        name = vname:gsub("_", " ")			
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1		
end
    send_large_msg(cb_extra.receiver, text)
end
--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
member_type = member_type:gsub("Admins","ادمین")	
member_type = member_type:gsub("Bots","ربات")		
local text = member_type.." های گروه <b>"..chat_name.." </b>:\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    --send_large_msg(cb_extra.receiver, text)
    reply_msg(cb_extra.msg.id, text, ok_cb,false)	
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="📃 اطلاعات گروه <b> "..result.title.." </b>\n\n"
local admin_num = "🌟 تعداد ادمین ها  : "..result.admins_count.."\n"
local user_num = "🔢 تعداد اعضا : "..result.participants_count.."\n"
local kicked_num = "♨️ تعداد اعضای اخراج شده : "..result.kicked_count.."\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num
    --send_large_msg(cb_extra.receiver, text)
    reply_msg(cb_extra.msg.id, text, ok_cb,false)	
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "اعضای گروه برای "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
	--vardump(result)
	local text = "اعضای اخراج شده "..cb_extra.receiver.."\n\n"
	local i = 1
	for k,v in pairsByKeys(result) do
		if not v.print_name then
			name = " "
		else
			vname = v.print_name:gsub("‮", "")
			name = vname:gsub("_", " ")
		end
		if v.username then
			name = name.." @"..v.username
		end
		text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
		i = i + 1
	end
	local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
	file:write(text)
	file:flush()
	file:close()
	send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_link_lock = data[tostring(target)]['settings']['lock_link']
  local hash = 'link:'..msg.to.id
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #لینک از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_link'] = 'yes'
    --save_data(_config.moderation.data, data)	
    redis:set(hash, true)			
    return reply_msg(msg.id,"🔒 قفل #لینک فعال شد !", ok_cb, false)
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_link_lock = data[tostring(target)]['settings']['lock_link']
  local hash = 'link:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #لینک فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_link'] = 'no'
    --save_data(_config.moderation.data, data)
    --local hash = 'link:'..msg.to.id
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #لینک غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_inline_lock = data[tostring(target)]['settings']['lock_inline']
  local hash = 'inline:'..msg.to.id
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #دکمه_شیشه_ای از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_inline'] = 'yes'
    --save_data(_config.moderation.data, data)	
    redis:set(hash, true)			
    return reply_msg(msg.id,"🔐 قفل #دکمه_شیشه_ای فعال شد !", ok_cb, false)
  end
end

local function unlock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_inline_lock = data[tostring(target)]['settings']['lock_inline']
  local hash = 'inline:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #دکمه_شیشه_ای فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_inline'] = 'no'
    --save_data(_config.moderation.data, data)
    --local hash = 'inline:'..msg.to.id
    redis:del(hash)		
    return reply_msg(msg.id,"🔐 قفل #دکمه_شیشه_ای غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_inline_lock = data[tostring(target)]['settings']['lock_tag']
  local hash = 'tag:'..msg.to.id
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #تگ از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_tag'] = 'yes'
    --save_data(_config.moderation.data, data)	
    redis:set(hash, true)			
    return reply_msg(msg.id,"🔐 قفل #تگ فعال شد !", ok_cb, false)
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_inline_lock = data[tostring(target)]['settings']['lock_tag']
  local hash = 'tag:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #تگ فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_tag'] = 'no'
    --save_data(_config.moderation.data, data)
    --local hash = 'tag:'..msg.to.id
    redis:del(hash)		
    return reply_msg(msg.id,"🔐 قفل #تگ غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  local hash = 'fwd:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #فروارد از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    --save_data(_config.moderation.data, data)		
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #فروارد فعال شد !", ok_cb, false)
  end
end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  local hash = 'fwd:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #فروارد فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_fwd'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #فروارد غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_reply_lock = data[tostring(target)]['settings']['lock_reply']
  local hash = 'reply:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #ریپلای از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_reply'] = 'yes'
    --save_data(_config.moderation.data, data)	
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #ریپلای فعال شد !", ok_cb, false)
  end
end

local function unlock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_reply_lock = data[tostring(target)]['settings']['lock_reply']
  local hash = 'reply:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #ریپلای فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_reply'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #ریپلای غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_cmd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_cmd_lock = data[tostring(target)]['settings']['lock_cmd']
  local hash = 'cmd:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #دستورات از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_cmd'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #دستورات فعال شد !", ok_cb, false)
  end
end

local function unlock_group_cmd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_cmd_lock = data[tostring(target)]['settings']['lock_cmd']
  local hash = 'cmd:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #دستورات فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_cmd'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #دستورات غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  local hash = 'spam:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #اسپم از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_spam'] = 'yes'
    --save_data(_config.moderation.data, data)		
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #اسپم فعال شد !", ok_cb, false)
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  local hash = 'spam:'..msg.to.id	
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #اسپم فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_spam'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)			
    return reply_msg(msg.id,"🔏 قفل #اسپم غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return reply_msg(msg.id,"🔐 قفل #فلود از قبل فعال است !", ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔒 قفل #فلود فعال شد !", ok_cb, false)
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return reply_msg(msg.id,"🔓 قفل #فلود فعال نیست !", ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,"🔏 قفل #فلود غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  local hash = 'persian:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #پارسی از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #پارسی فعال شد !", ok_cb, false)
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  local hash = 'persian:'..msg.to.id		
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #پارسی فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_arabic'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #پارسی غیرفعال شد !", ok_cb, false)
  end
end



local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local hash = 'tgservice:'..msg.to.id	
  --local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #سرویس تلگرام از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #سرویس تلگرام فعال شد !", ok_cb, false)
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  local hash = 'tgservice:'..msg.to.id		
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #سرویس تلگرام فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #سرویس تلگرام غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  local hash = 'sticker:'..msg.to.id	
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #استیکر از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #استیکر فعال شد !", ok_cb, false)
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  local hash = 'sticker:'..msg.to.id		
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #استیکر فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_sticker'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #استیکر غیرفعال شد !", ok_cb, false)
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  local hash = 'contact:'..msg.to.id		
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #مخاطب از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #مخاطب فعال شد !", ok_cb, false)
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  local hash = 'contact:'..msg.to.id			
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #مخاطب فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['lock_contacts'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #مخاطب غیرفعال شد !", ok_cb, false)
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_strict_lock = data[tostring(target)]['settings']['strict']
  local hash = 'strict:'..msg.to.id				
  if redis:get(hash) then
    return reply_msg(msg.id,"🔐 قفل #سختگیرانه از قبل فعال است !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['strict'] = 'yes'
    --save_data(_config.moderation.data, data)
    redis:set(hash, true)		
    return reply_msg(msg.id,"🔒 قفل #سختگیرانه فعال شد !", ok_cb, false)
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  --local group_strict_lock = data[tostring(target)]['settings']['strict']
  local hash = 'strict:'..msg.to.id				
  if not redis:get(hash) then
    return reply_msg(msg.id,"🔓 قفل #سختگیرانه فعال نیست !", ok_cb, false)
  else
    --data[tostring(target)]['settings']['strict'] = 'no'
    --save_data(_config.moderation.data, data)
    redis:del(hash)		
    return reply_msg(msg.id,"🔏 قفل #سختگیرانه غیرفعال شد !", ok_cb, false)
  end
end

-- //Photo Lock\\ --
local function lock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #عکس فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #عکس از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #عکس غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #عکس فعال نیست !", ok_cb, false)
				end

end
-- //Photo Lock\\ --

-- //Video Lock\\ --
local function lock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #فیلم فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #فیلم از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #فیلم غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #فیلم فعال نیست !", ok_cb, false)
				end

end
-- //Video Lock\\ --

-- //Audio Lock\\ --
local function lock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #صدا فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #صدا از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #صدا غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #صدا فعال نیست !", ok_cb, false)
				end

end
-- //Audio Lock\\ --

-- //File Lock\\ --
local function lock_group_documents(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #فایل فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #فایل از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_documents(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #فایل غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #فایل فعال نیست !", ok_cb, false)
				end

end
-- //File Lock\\ --

-- //Gif Lock\\ --
local function lock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #گیف فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #گیف از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #گیف غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #گیف فعال نیست !", ok_cb, false)
				end

end
-- //Gif Lock\\ --

-- //Gif Lock\\ --
local function lock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #گیف فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #گیف از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #گیف غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #گیف فعال نیست !", ok_cb, false)
				end

end
-- //Gif Lock\\ --

-- //Text Lock\\ --
local function lock_group_text(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #متن فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #متن از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_text(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #متن غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #متن فعال نیست !", ok_cb, false)
				end

end
-- //Text Lock\\ --

-- //All Lock\\ --
local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					mute(chat_id, msg_type)
					local text = "🔒 قفل #گروه فعال شد !"
					return reply_msg(msg.id, text, ok_cb, false)
				else 
					local text = "🔐 قفل #گروه از قبل فعال است !"
					return reply_msg(msg.id, text, ok_cb, false)
				end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
				local chat_id = msg.to.id	
	local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					unmute(chat_id, msg_type)
    return reply_msg(msg.id,"🔓 قفل #گروه غیرفعال شد !", ok_cb, false)

		
				else
    return reply_msg(msg.id,"🔓 قفل #گروه فعال نیست !", ok_cb, false)
				end

end
-- //All Lock\\ --

--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'قوانین'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  local text = '✅ قوانین گروه تنظیم شد !'
  return reply_msg(msg.id, text, ok_cb, false)	
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
   local text = '❌ قوانین تنظیم نشده است !'
   return reply_msg(msg.id, text, ok_cb, false)	
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  --local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = '📋 قوانین گروه <b>'..msg.to.title..' </b>:\n'..rules
  --return rules
  return reply_msg(msg.id, rules, ok_cb, false)		
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
      --[[if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'

		end
	end]]
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['flood'] then
			data[tostring(target)]['settings']['flood'] = 'no'
		end
	end
      --[[if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_link'] then
			data[tostring(target)]['settings']['lock_link'] = 'no'
		end
	end]]	
      --[[if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fwd'] then
			data[tostring(target)]['settings']['lock_fwd'] = 'no'
		end
	end]]	
local hash1 = 'link:'..msg.to.id
local hash2 = 'fwd:'..msg.to.id
local hash3 = 'reply:'..msg.to.id
local hash4 = 'cmd:'..msg.to.id
local hash5 = 'spam:'..msg.to.id
local hash6 = 'persian:'..msg.to.id
local hash7 = 'tgservice:'..msg.to.id
local hash8 = 'sticker:'..msg.to.id
local hash9 = 'contact:'..msg.to.id
local hash10 = 'strict:'..msg.to.id
local hash11 = 'inline:'..msg.to.id
local hash12 = 'tag:'..msg.to.id

if redis:get(hash1) then
link = 'yes'
else
link = 'no'		
end		

if redis:get(hash2) then
fwd = 'yes'
else
fwd = 'no'		
end		

if redis:get(hash3) then
reply = 'yes'
else
reply = 'no'		
end		

if redis:get(hash4) then
cmd = 'yes'
else
cmd = 'no'		
end		

if redis:get(hash5) then
spam = 'yes'
else
spam = 'no'		
end		

if redis:get(hash6) then
persian = 'yes'
else
persian = 'no'		
end		

if redis:get(hash7) then
tgservice = 'yes'
else
tgservice = 'no'		
end		

if redis:get(hash8) then
sticker = 'yes'
else
sticker = 'no'		
end		

if redis:get(hash9) then
contact = '🔊'
else
contact = '🔇'		
end		

if redis:get(hash10) then
strict = 'yes'
else
strict = 'no'		
end	

if redis:get(hash11) then
inline = 'yes'
else
inline = 'no'		
end	

if redis:get(hash12) then
tag = 'yes'
else
tag = 'no'		
end	
	
if is_muted(tostring(target), 'Audio: yes') then
 Audio = '🔊'
 else
 Audio = '🔇'
 end
    if is_muted(tostring(target), 'Photo: yes') then
 Photo = '🔊'
 else
 Photo = '🔇'
 end
    if is_muted(tostring(target), 'Video: yes') then
 Video = '🔊'
 else
 Video = '🔇'
 end
    if is_muted(tostring(target), 'Gifs: yes') then
 Gifs = '🔊'
 else
 Gifs = '🔇'
 end
 if is_muted(tostring(target), 'Documents: yes') then
 Documents = '🔊'
 else
 Documents = '🔇'
 end
 if is_muted(tostring(target), 'Text: yes') then
 Text = '🔊'
 else
 Text = '🔇'
 end
  if is_muted(tostring(target), 'All: yes') then
 All = '🔊'
 else
 All = '🔇'
 end	

local expiretime = redis:hget('expiretime', get_receiver(msg))
    local expire = ''
  if not expiretime then
  expire = '0'
  else
   local now = tonumber(os.time())
   expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
 end	
	
  local settings = data[tostring(target)]['settings']
  --local text = "⚙ تنظیمات گروه <b>"..msg.to.print_name.." </b>:\n\n[🔐]  <i>قفل های عادی </i>:\n\n🔷 قفل #فلود : "..settings.flood.."\n🔶 حساسیت فلود : "..NUM_MSG_MAX.."\n🔷 قفل #اسپم : "..settings.lock_spam.."\n\n🔶 قفل #پارسی : "..settings.lock_arabic.."\n🔷 قفل #لینک : "..settings.lock_link.."\n🔶 قفل #فروارد : "..settings.lock_fwd.."\n🔷 قفل #سرویس تلگرام : "..settings.lock_tgservice.."\n🔶 قفل #سختگیرانه : "..settings.strict.."\n♨️ تاریخ انقضا : "..expire.."\n\n[🔏] <i> قفل های رسانه </i>:\n\n🔵 قفل #متن : "..Text.."\n🔴 قفل #عکس : "..Photo.."\n🔵 قفل #فیلم : "..Video.."\n🔴 قفل #صدا : "..Audio.."\n🔵 قفل #گیف : "..Gifs.."\n🔴 قفل #فایل : "..Documents.."\n🔵 قفل #همه : "..All
  local text = "⚙ تنظیمات گروه <b>"..msg.to.print_name.." </b>:\n\n[🔐]  <i>قفل های عادی </i>:\n➖➖➖➖➖➖➖➖➖\n🔲 پاکننده #فلود : "..settings.flood.."\n🔲حساسیت  : "..NUM_MSG_MAX.."\n🔲پاکننده #اسپم : "..spam.."\n🔲 پاکننده #فارسی : "..persian.."\n🔲️ پاکننده #لینک : "..link.."\n🔲پاکننده #فروارد : "..fwd.."\n🔲️پاکننده #دکمه شیشه ای : "..inline.."\n🔲 پاکننده #تگ : "..tag.."\n️ پاکننده #سرویس تلگرام : "..tgservice.."\n🔲️ پاکننده #دستورات : "..cmd.."\n🔲قفل #سختگیرانه : "..strict.."\n⏰ تاریخ انقضا : "..expire.." روز دیگر\n\n[🔏] قفل های رسانه :\n➖➖➖➖➖➖➖➖➖\n📑️پاکننده #متن : "..Text.."\n📷️ پاکننده #عکس : "..Photo.."\n 🎥پاکننده #فیلم : "..Video.."\n🎤 پاکننده #صدا : "..Audio.."\n🎠️ پاکننده #گیف : "..Gifs.."\n📂 پاکننده #فایل : "..Documents.."\n📞️ پاکننده #مخاطب : "..contact.."\n💭قفل #گروه(همه چیز) : "..All	
        text = text:gsub("yes","✔")
        text = text:gsub("no","⭕️️")
	     text = text:gsub("🔊","✔")
        text = text:gsub("🔇","🚫")
  return reply_msg(msg.id, text, ok_cb, false)
  --send_api_msg(msg, get_receiver_api(msg), text, true, 'md')	
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '@')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, '‼️ کاربر '..member_username..' از قبل مدیر است !')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, '‼️ کاربر '..member_tag_username..' مدیر نیست !')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '@')
  if not data[group] then
    return send_large_msg(receiver, '')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, '‼️ کاربر '..member_username..' از قبل مدیر است !')
		
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, '🕵 کاربر '..member_username..' مدیر شد !')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, '')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' has been demoted.')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'SuperGroup is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return 'No moderator in this group.'
  end
  local i = 1
  local message = '🔰 لیست مدیران گروه <b>'..msg.to.title..' </b>:\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	if type(result) == 'boolean' then
		print('This is a old message!')
		return
	end
	if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
		--id1 = reply_msg(result.id, result.from.peer_id, ok_cb,false)

	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			--id1 = send_large_msg(channel, user_id)
			id1 = reply_msg(result.id, user_id, ok_cb,false)
		end
	elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
		--id2 = reply_msg(result.id, result.fwd_from.peer_id, ok_cb,false)
	elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		----savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." set as an admin"
		else
			text = "[ "..user_id.." ]set as an admin"
		end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." has been demoted from admin"
		else
			text = "[ "..user_id.." ] has been demoted from admin"
		end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "👮🏼 کاربر [<b>"..result.from.peer_id.."] </b>@"..result.from.username.." به عنوان صاحب گروه انتخاب شد !"	

			else
				text = "👮🏼 کاربر [<b>"..result.from.peer_id.."] </b>به عنوان صاحب گروه انتخاب شد !"	
			end
			--send_large_msg(channel_id, text)
			reply_msg(result.id, text, ok_cb,false)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
elseif get_cmd == 'mute_user' then
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
  if not is_muted_user(chat_id, user_id) then
          mute_user(chat_id, user_id)
        --send_large_msg(receiver, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا اضافه شد !")
	reply_msg(extra.msg.id, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا اضافه شد !", ok_cb,false)		
  else
  mute_user(chat_id, user_id)
        send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از قبل در لیست افراد بی صدا است !")
  end
  elseif get_cmd == 'unmute_user' then
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
  if is_muted_user(chat_id, user_id) then
          unmute_user(chat_id, user_id)
        send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا حذف شد !")
  elseif is_momod(extra.msg) then
    unmute_user(chat_id, user_id)
        send_large_msg(receiver, "🚫 کاربر <b>["..user_id.."] </b>در لیست افراد بی صدا نیست !")
  end
 end
end
--End resolve username actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] has been demoted from admin"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			--savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been demoted from admin"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
		
elseif get_cmd == 'mute_user' then
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
  if not is_muted_user(chat_id, user_id) then
          mute_user(chat_id, user_id)
        --send_large_msg(receiver, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا اضافه شد !")
	reply_msg(extra.msg.id, "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا اضافه شد !", ok_cb,false)		
  else
  mute_user(chat_id, user_id)
        --send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از قبل در لیست افراد بی صدا است !")
	reply_msg(extra.msg.id, "🔊 کاربر <b>["..user_id.."] </b>از قبل در لیست افراد بی صدا است !", ok_cb,false)			
  end
  elseif get_cmd == 'unmute_user' then
  local user_id = result.peer_id
  local receiver = extra.receiver
  local chat_id = string.gsub(receiver, 'channel#id', '')
  if is_muted_user(chat_id, user_id) then
          unmute_user(chat_id, user_id)
        --send_large_msg(receiver, "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا حذف شد !")
	reply_msg(extra.msg.id, "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا حذف شد !", ok_cb,false)			
  elseif is_momod(extra.msg) then
    unmute_user(chat_id, user_id)
        --send_large_msg(receiver, "🚫 کاربر <b>["..user_id.."] </b>در لیست افراد بی صدا نیست !")
        reply_msg(extra.msg.id, "🚫 کاربر <b>["..user_id.."] </b>در لیست افراد بی صدا نیست !", ok_cb,false)			
		
  end
 end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'No user @'..member..' in this SuperGroup.'
  else
    text = 'No user ['..memberid..'] in this SuperGroup.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = ""
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] has been set as an admin"
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        --savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					--savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = "👮🏼 کاربر [<b>"..v.peer_id.."] </b>@"..member_username.." به عنوان صاحب گروه انتخاب شد !"	
				else
					text = "👮🏼 کاربر [<b>"..v.peer_id.."] </b>به عنوان صاحب گروه انتخاب شد !"	
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				--savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
			         text = "👮🏼 کاربر ["..memberid.."] به عنوان صاحب گروه انتخاب شد !"	
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)	
	if msg.to.type == 'chat' then
		if matches[1]:lower() == 'tosuper' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1]:lower() == 'تبدیل' then
			if not is_admin1(msg) then
				return
			end
			return "Already a SuperGroup"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1]:lower() == 'فعال' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '❇️ گروه <b>'..msg.to.title..' </b>از قبل در لیست گروه های تحت مدیریت ربات است !', ok_cb, false)
			end
			--print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1]:lower() == 'غیر فعال' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, '❇️ گروه <b>'..msg.to.title..' </b>در لیست گروه های تحت مدیریت ربات نیست !', ok_cb, false)
			end
			--print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1]:lower() == "gpinfo" then
			if not is_owner(msg) then
				return
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1]:lower() == "admins" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1]:lower() == "padmin" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,promoteadmin, {receiver = receiver, msg = msg, member_type = member_type})
		end
		
		if matches[1]:lower() == "صاحب" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "no owner,ask admins in support groups to set owner for your SuperGroup"
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			local text = "⚜ کاربر [<b>"..group_owner.."] </b> صاحب گروه است ! "
			return reply_msg(msg.id, text, ok_cb, false)
		end

		if matches[1]:lower() == "modlist" then
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			local text = modlist(msg)
			return reply_msg(msg.id, text, ok_cb, false)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1]:lower() == "ربات ها" and is_momod(msg) then
			member_type = 'Bots'
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1]:lower() == "who" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1]:lower() == "kicked" and is_momod(msg) then
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1]:lower() == 'حذف' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1]:lower() == 'block' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'block' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1]:lower() == "block" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1]:lower() == 'ایدی' then
		if redis:get("id:"..msg.to.id..":"..msg.from.id) and not is_momod(msg) then
                 return
                end
               redis:setex("id:"..msg.to.id..":"..msg.from.id, 30, true)	
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				local text = "شناسه شما : <b> ["..msg.from.id.."] </b>\nشناسه گروه : <b> ["..msg.to.id.."</b>]"
				return reply_msg(msg.id,text,ok_cb,false)
			end
		end

		if matches[1]:lower() == 'kickme' then
			if msg.to.type == 'channel' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1]:lower() == 'لینک جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '*Error: Failed to retrieve link* \nReason: Not creator.\n\nIf you have the link, please use /setlink to set it')					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "Created a new link")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1]:lower() == 'ست لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			local text = '💱 لینک گروه را بفرستید :'
			return reply_msg(msg.id,text,ok_cb,false)
		end

		if msg.text then
			if msg.text:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				--return "New link set"
				return reply_msg(msg.id, "✅ لینک گروه <b>"..msg.to.title.." </b> تنظیم شد !\n "..msg.text.."", ok_cb, false)
			end
		end

		if matches[1]:lower() == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				local text = "⚠️ لینک گروه را با دستور <b>Setlink </b> ذخیره کنید !"
				return reply_msg(msg.id,text,ok_cb,false)
			end
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			local text = "♐️ لینک گروه <b>"..msg.to.title.." </b>:\n"..group_link
		        return reply_msg(msg.id, text, ok_cb, false)
		end

		if matches[1]:lower() == "invite" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1]:lower() == 'res' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1]:lower() == 'kick' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1]:lower() == 'setadmin' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'setadmin' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'setadmin'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1]:lower() == 'setadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1]:lower() == 'demoteadmin' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'demoteadmin' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1]:lower() == 'demoteadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1]:lower() == 'تنظیم صاحب' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'setowner' and matches[2] and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1]:lower() == 'setowner' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1]:lower() == 'ادمین' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'promote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1]:lower() == 'promote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1]:lower() == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1]:lower() == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1]:lower() == 'تنزل ادمین' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1]:lower() == 'demote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1]:lower() == 'demote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1]:lower() == "setname" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
			return reply_msg(msg.id, "✳️ نام گروه به <b>"..matches[2].." </b> تغییر کرد !", ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1]:lower() == "setabout" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "Description has been set.\n\nSelect the chat again to see the changes."
		end

		if matches[1]:lower() == 'setrules' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1]:lower() == 'setphoto' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'Please send the new group photo now'
		end	
             if matches[1]:lower() == 'clean' then			
		 if matches[2]:lower() == 'banlist' and is_momod(msg) then
		    local chat_id = msg.to.id
                     local hash = 'banned:'..chat_id
                     local data_cat = 'banlist'
                     data[tostring(msg.to.id)][data_cat] = nil
                     save_data(_config.moderation.data, data)
                     redis:del(hash)
		     return reply_msg(msg.id,"♨️ لیست کاربران بن شده خالی شد !",ok_cb, false)
		end
		if matches[2]:lower() == 'superbanlist' and is_sudo(msg) then 
                     local hash = 'gbanned'
                     local data_cat = 'gbanlist'
                     data[tostring(msg.to.id)][data_cat] = nil
                     save_data(_config.moderation.data, data)
                     redis:del(hash)
		     return reply_msg(msg.id,"♨️ لیست کاربران سوپر بن خالی شد !", ok_cb,false)
		end		
		if matches[2]:lower() == 'deleted' and is_momod(msg) then
	         local receiver = get_receiver(msg) 
                 channel_get_users(receiver, check_member_super_deleted,{receiver = receiver, msg = msg})
		end	
			if matches[2] == 'modlist' and is_owner(msg) then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					--return 'مدیری در لیست مدیران وجود ندارد'
					return reply_msg(msg.id,'مدیری در لیست مدیران وجود ندارد',ok_cb,false)
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				--return 'لیست ادمین های گروه پاکسازی شد'
				return reply_msg(msg.id,'لیست مدیران گروه پاکسازی شد',ok_cb,false)
			end
			if matches[2] == 'rules' and is_owner(msg) then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					--return "قوانین ثبت شد"
					return reply_msg(msg.id,'قوانین گروه جهت پاکسازی وجود ندارد',ok_cb,false)
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return reply_msg(msg.id,'قوانین گروه پاکسازی شد',ok_cb,false)
			end
			if matches[2] == 'about' and is_owner(msg) then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					--return 'اطلاعاتی ثبت نشده است'
					return reply_msg(msg.id,'اطلاعاتی ثبت نشده است',ok_cb,false)
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				--return "اطلاعات پاکسازی شد"
				return reply_msg(msg.id,'اطلاعات پاکسازی شد',ok_cb,false)
			end
			if matches[2] == 'mutelist' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				--return "لیست کاربران موت شده پاکسازی شد"
				return reply_msg(msg.id,'لیست کاربران موت شده پاکسازی شد',ok_cb,false)
			end
			if matches[2] == 'username' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "bots" and is_momod(msg) then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

		if matches[1]:lower() == 'قفل' and is_momod(msg) then
			local target = msg.to.id
			
			if matches[2] == 'عکس' then
				return lock_group_photo(msg, data, target)
			end	
			if matches[2] == 'فیلم' then
				return lock_group_video(msg, data, target)
			end
			if matches[2] == 'گیف' then
				return lock_group_gif(msg, data, target)
			end
			if matches[2] == 'صدا' then
				return lock_group_audio(msg, data, target)
			end			
			if matches[2] == 'فایل' then
				return lock_group_documents(msg, data, target)
			end
			if matches[2] == 'متن' then
				return lock_group_text(msg, data, target)
			end
			if matches[2] == 'همه' then
				return lock_group_all(msg, data, target)
			end									
			
			if matches[2] == 'لینک' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_fwd(msg, data, target)
			end	
			if matches[2] == 'ریپلی' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_reply(msg, data, target)
			end
			if matches[2] == 'کامنت' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_cmd(msg, data, target)
			end			
			if matches[2] == 'اسپم' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'فلود' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'عربی' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
           if matches[2] == 'ممبر' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return unlock_group_membermod(msg, data, target)
			end
          if matches[2] == 'ار تی ال' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
			if matches[2] == 'سرویس تلگرام' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'شماره' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'انلاین' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_inline(msg, data, target)
			end
			if matches[2] == 'تگ' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_tag(msg, data, target)
			end
			if matches[2] == 'سخت گیرانه' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1]:lower() == 'بازکردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'عکس' then
				return unlock_group_photo(msg, data, target)
			end	
			if matches[2] == 'فیلم' then
				return unlock_group_video(msg, data, target)
			end
			if matches[2] == 'صدا' then
				return unlock_group_audio(msg, data, target)
			end				
			if matches[2] == 'گیف' then
				return unlock_group_gif(msg, data, target)
			end
			if matches[2] == 'فایل' then
				return unlock_group_documents(msg, data, target)
			end
			if matches[2] == 'متن' then
				return unlock_group_text(msg, data, target)
			end
			if matches[2] == 'همه' then
				return unlock_group_all(msg, data, target)
			end	
			
			if matches[2] == 'لینک' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'انلاین' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_inline(msg, data, target)
			end
			if matches[2] == 'تگ' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_tag(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return unlock_group_fwd(msg, data, target)
			end		
			if matches[2] == 'ریپلی' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return unlock_group_reply(msg, data, target)
			end			
			if matches[2] == 'اسپم' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'کامنت' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_cmd(msg, data, target)
			end			
			if matches[2] == 'فلود' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'عربی' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'ممبر' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2]:lower() == 'ار تی ال' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
				if matches[2] == 'سرویس تلگرام' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'شماره' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'سخت گیرانه' then
				--savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1]:lower() == 'ست فلود' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 30 then
			 local text = '❌ عددی بین <b>3 </b>تا <b>30 </b>وارد کنید !'
			 return reply_msg(msg.id, text, ok_cb, false)
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			local text = '☢ حساسیت اسپم بر روی <b>'..matches[2]..' </b>تنظیم شد !'
			return reply_msg(msg.id, text, ok_cb, false)
		end
if matches[1]:lower() == "حذف سایلنت" and is_momod(msg) then
local chat_id = msg.to.id
local hash = "mute_user"..chat_id
local user_id = ""
if type(msg.reply_id) ~= "nil" then
local receiver = get_receiver(msg)
local get_cmd = "unmute_user"
local cbres_extra = {
	channel = get_receiver(msg),
	get_cmd = 'unmute_user',
	msg = msg					
	}				
--muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
muteuser = get_message(msg.reply_id, get_message_callback, cbreply_extra)				
elseif matches[1]:lower() == "حذف سایلنت" and matches[2] and string.match(matches[2], '^%d+$') then
local user_id = matches[2]
if is_muted_user(chat_id, user_id) then
unmute_user(chat_id, user_id)
--savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
 local text = "🔊 کاربر <b>["..user_id.."] </b>از لیست افراد بی صدا حذف شد !"
 return reply_msg(msg.id, text, ok_cb, false)
elseif is_momod(msg) then
--savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
 local text = "🚫 کاربر <b>["..user_id.."] </b>در لیست افراد بی صدا نیست !"
 return reply_msg(msg.id, text, ok_cb, false)
end
elseif matches[1]:lower() == "حذف سایلنت" and matches[2] and not string.match(matches[2], '^%d+$') then
local receiver = get_receiver(msg)
local get_cmd = "unmute_user"
local username = matches[2]
local username = string.gsub(matches[2], '@', '')
resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
end
end
  if matches[1]:lower() == "سایلنت" and is_momod(msg) then
   local chat_id = msg.to.id
   local hash = "mute_user"..chat_id
   local user_id = ""
   if type(msg.reply_id) ~= "nil" then
    local receiver = get_receiver(msg)
    local get_cmd = "mute_user"
    muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
   elseif matches[1]:lower() == "سایلنت" and matches[2] and string.match(matches[2], '^%d+$') then
    local user_id = matches[2]
    if not is_muted_user(chat_id, user_id) then
mute_user(chat_id, user_id)
--savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
--savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
local text = "🔇 کاربر <b>["..user_id.."] </b>به لیست افراد بی صدا اضافه شد !"
return reply_msg(msg.id, text, ok_cb, false)
elseif is_momod(msg) then
local text = "✳️ کاربر <b>["..user_id.."] </b> از قبل در لیست افراد بی صدا است !"
return reply_msg(msg.id, text, ok_cb, false)
end
   elseif matches[1]:lower() == "سایلنت" and matches[2] and not string.match(matches[2], '^%d+$') then
    local receiver = get_receiver(msg)
    local get_cmd = "mute_user"
    local username = matches[2]
    local username = string.gsub(matches[2], '@', '')
    resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
   end
  end

		if matches[1]:lower() == "لیست سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1]:lower() == 'تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1]:lower() == 'قوانین' then
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1]:lower() == 'peer_id' and is_admin1(msg) then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1]:lower() == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					--savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					--savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					--savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					--savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1]:lower() == 'msg.to.peer_id' and is_sudo(msg) then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^(فعال)$",
	"^(غیر فعال)$",
		
	"^([Gg][Pp][Ii][Nn][Ff][Oo])$",
	"^([Aa][Dd][Mm][Ii][Nn][Ss])$",
	"^([Pp][Aa][Dd][Mm][Ii][Nn])$",		
	"^([Oo][Ww][Nn][Ee][Rr])$",
	"^([Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
	"^([Bb][Oo][Tt][Ss])$",
	"^([Ww][Hh][Oo])$",
	"^([Rr][Ee][Ss]) (.*)$",		
	"^([Kk][Ii][Cc][Kk][Ee][Dd])$",
		
        "^([Kk][Ii][Cc][Kk]) (.*)",
	"^([Kk][Ii][Cc][Kk])",
		
	"^(تبدیل)$",
		
	"^(ایدی)$",
	"^(ایدی) (.*)$",


 	"^(لینک جدید)$",
	"^(ست لینک)$",
	"^(لینک)$",

	"^(تنظیم صاحب) (.*)$",
	"^(تنظیم صاحب)$",
	"^(ادمین) (.*)$",
	"^(ادمین)",
	"^(تنزل ادمین) (.*)$",
	"^(تنزل ادمین)",
		
	"^([Ss][Ee][Tt][Nn][Aa][Mm][Ee]) (.*)$",
	"^([Ss][Ee][Tt][Aa][Bb][Oo][Uu][Tt]) (.*)$",
	"^([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$",
	"^([Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo])$",

	"^(حذف)$",
		
	"^(قفل) (.*)$",
	"^(بازکردن) (.*)$",
		
	"^(سایلنت)$",
	"^(سایلنت) (.*)$",
	"^(حذف سایلنت)$",
	"^(حذف سایلنت) (.*)$",	
		
	"^(تنظیمات)$",
	"^(قوانین)$",		
	"^(ست فلود) (%d+)$",		
	"^([Cc][Ll][Ee][Aa][Nn]) (.*)$",
	"^(لیست سایلنت)$",
        "([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)",
  
   "([https?://w]*.?telegram.me/joinchat/%S+)",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
     "^!!tgservice",
     "(chat_add_user)$",
     "^!!tgservice",
     "(chat_add_user_link)$",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua