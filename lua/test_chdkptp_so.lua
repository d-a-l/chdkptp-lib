require('io')
require('os')
require('lfs')

require('chdkptp')

require('lbuf')
require('rawimg')

util=require('util')
util:import()
ustime=require('ustime')
fsutil=require('fsutil')
prefs=require('prefs')
varsubst=require('varsubst')
chdku=require('chdku')
cli=require('cli')
exp=require('exposure')
dng=require('dng')
dngcli=require('dngcli')


print("conectando")
local devices = chdk.list_usb_devices()

print("comprobando si hay devices conectados")
if not next(devices) then
  print(" Aparentemente no hay cámaras conectadas al equipo\n")
  return
end

cams={}

for i, devinfo in ipairs(devices) do
	print('['..tostring(i)..'] '.."iniciando con con chdku")
	local lcon=chdku.connection(devinfo)

	print('['..tostring(i)..'] '.."comprobando conexion")
	if lcon:is_connected() then
	    print('['..tostring(i)..'] '.." - conectada!")
	    lcon:update_connection_info()
	else
	    print('['..tostring(i)..'] '.." - no esta conectada, intentando conectar")
	    
            lcon:connect()
            -- con.condev=con:get_con_devinfo()
	    if lcon:is_connected() then
	       print('['..tostring(i)..'] '.." - conectada!")
	    end
	end

	print('['..tostring(i)..'] '..': dev:'..tostring(lcon.condev.dev)..', bus:'..tostring(lcon.condev.bus)..'\n')
        table.insert(cams,lcon)
end

print("cruzando los dedos...")
for i, lcon in ipairs(cams) do
	local status, data, err = lcon:execwait([[
	local rec,vid,mode = get_mode()
	if rec == false then
	  -- Set the camera to record mode
	  switch_mode_usb(1)
	  sleep(100)
	else
	  switch_mode_usb(0)
	  sleep(100)
	end
	return true, 'sarasa texto desde funcion'
	]] )

	print('['..tostring(i)..'] '..'status:'..tostring(status)..' data:'..tostring(data)..' error:'..tostring(err))
end
print('chaucito')

--[[

    local cams={}
    if not next(devices) then
        print(" Aparentemente no hay cámaras conectadas al equipo\n")
        return
    end
    for i, devinfo in ipairs(devices) do
        local lcon,msg = chdku.connection(devinfo)
        -- if not already connected, try to connect
        if lcon:is_connected() then
            print(tostring(i).." - conectada!")
            lcon:update_connection_info()
        else
            print(tostring(i).." - no esta conectada, intentando conectar")
            local status,err = lcon:connect()
            if not status then
                print(tostring(i)..': coneccion fallo! dev:'..tostring(devinfo.dev)..', bus:'..tostring(devinfo.bus)..', err:'..tostring(err)..'\n')
                connect_fail = true
            end
        end) 
        -- if connection didn't fail
        if lcon:is_connected() then
            print( tostring(i)..' - '
                ..'model:'..tostring(lcon.ptpdev.model)..' '
                ..'bus:'..tostring(lcon.condev.bus)..' '
                ..'dev:'..tostring(lcon.condev.dev)..' '
                ..'sn:'..tostring(lcon.ptpdev.serial_number)
            )
            lcon.mc_id = string.format('%d:%s',i,lcon.ptpdev.model)
            lcon.sn = tostring(lcon.ptpdev.serial_number)
            -- -- --
            table.insert(cams,lcon)
            -- -- --
        end
    end
    print()
    if connect_fail then
        print('conexion fallo')
    else
        print('conexion exitos')
    end
-- end



--]]