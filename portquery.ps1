function revisar_variables {
    param (
        [String] $ip,
        [String] $arxiu,
        [String] $arxiu_ruta,
        [String] $arxiu_force,
        [String] $rangs
    )
    
    $array_ip = $ip.Split(".")
    if ($array_ip.Count -eq 4) {
        foreach ($bloc in $array_ip) {
            if (($bloc.length -gt 0)-and ($bloc.length -le 4))
            {
               
            }
            else 
            {
                Write-Warning "La ip no es correcte"
                break
            }
        }
    }

    if (($arxiu -eq "T") -or ($arxiu -eq "F") -or ($arxiu -eq "") -or (-Not $arxiu)) {
        #CORRECTE   
    }else {
        Write-Warning "El parametre d'arxiu [-arxiu] no es correcte (T/F)"
        break
    }

    if (($arxiu_ruta -eq "T") -and ((Test-Path -Path $arxiu_ruta) -eq "False")) {
        Write-Warning "La ruta no existeix"
        break  
    }else {
        
    }

    if (($arxiu_force -eq "T") -or ($arxiu_force -eq "F") -or ($arxiu_force -eq "") -or (-Not $arxiu_force)) {
        #CORRECTE
        
    }else {
        Write-Warning "El parametre d'arxiu force [-arxiu_force] no es correcte (T/F)"
        break
    }

    $array_rangs = $rangs.Split(",")
  
    if($array_rangs.length -eq 2)
    {
        #Correcte
        $port_u = [int]$array_rangs[0]
        $port_d = [int]$array_rangs[1]
        
        if (($port_u -ge 0) -and ($port_u -le 65535)) {
            #CORRECTE
        }
        else 
        {
            Write-Warning "El primer port es massa gran"
            break 
        }
        if (($port_d -ge 0) -and ($port_d -le 65535)) {
            #CORRECTE
        }
        else
        {
            Write-Warning "El primer port es massa gran"
            break            
        }
    }
}

function crear_excel {
    param (
        [String] $ip,
        [String] $arxiu_ruta,
        [String] $arxiu_force
    )
    $nom = "$ip.csv"
    if (($arxiu_force -eq "T")) 
    {
        New-Item -Path $arxiu_ruta -Name $nom -ItemType File -Value "port,resultat" -Force
    }
    else 
    {
        New-Item -Path $arxiu_ruta -Name $nom -ItemType File
    }
    $ruta = "$arxiu_ruta\$nom"
    "port,resultat" | Out-File $ruta
    return $ruta
    
}

function Test_ports {
    param (
        [String]$rangs,
        [String]$ip,
        [String]$fitxer
    )
    
    $array_rangs = $rangs.Split(",")
    $portu = [int]$array_rangs[0]
    $portd = [int]$array_rangs[1]
    for ($i = $portu; $i -le $portd; $i++) {
        $tn = (Test-NetConnection -ComputerName $ip -Port $i).tcptestsucceeded
        if( $tn -eq "True")
        {
            Write-Warning "$portu, True"
            
        }
        
        $fitxer_final = $fitxer.Split(" ")
        Write-Host $fitxer_final[0]
        $s = "$i,$tn"
        $s | Out-File $fitxer_final[0] -Append
        
    }
}

function zona_control {
    param (
        [String] $ip,
        [String] $arxiu,
        [String] $arxiu_ruta,
        [String] $arxiu_force,
        [String] $rangs
    )
    $fitxer = ""
    revisar_variables -ip $ip -arxiu $arxiu -arxiu_ruta $arxiu_ruta -arxiu_force $arxiu_force -rangs $rangs
    if ($arxiu -eq "T") {
        $fitxer = crear_excel -ip $ip -arxiu_ruta $arxiu_ruta -arxiu_force $arxiu_force
    }else {
        $fitxer = "F"
    }

    Test_ports -rangs $rangs -ip $ip -fitxer $fitxer
    
}

function impresora {
    param (
        [String]$ip,
        [String]$arxiu,
        [String]$arxiu_ruta,
        [string]$arxiu_force,
        [String]$rangs
    )
    if ((-Not $ip) -or ($ip -eq "")) {
        Write-Host "Cal escriure la ip [-ip]"
    }
    if ((-Not $arxiu) -or ($arxiu -eq "")) {
        Write-Host "Cal especificar si vols generar un fitxer [-arxiu]"
    }
    if ((-Not $arxiu_ruta) -and ($arxiu -eq "T")) {
        Write-Host "Cal especificar la ruta de l'arxiu [-arxiu_ruta]"
    }
    if (((-Not $arxiu_force) -and ($arxiu -eq 'T')) -or ($arxiu_force -eq "")) {
        Write-Host "Cal especificar si vols eliminar l'anterior arxiu si existeix [-arxiu_force]"
    }
    if (-Not $rangs) {
        $rangs = "0,65535"
    }
    Write-Host "Rang: "$rangs

    zona_control -ip $ip -arxiu $arxiu -arxiu_ruta $arxiu_ruta -arxiu_force $arxiu_force -rangs $rangs
}
