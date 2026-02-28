# Ejecutar PowerShell como Administrador

# Ruta del CSV
$csvPath = ".\users.csv"

# Password para todos (cámbialo si quieres)
$plainPassword  = "Passw0rd!2024"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

# Crear grupos si no existen
$groups = @("Innkaup","Sala","Yfirstjórn","Allir")
foreach ($g in $groups) {
    if (-not (Get-LocalGroup -Name $g -ErrorAction SilentlyContinue)) {
        New-LocalGroup -Name $g | Out-Null
        Write-Host "Grupo creado: $g"
    }
}

# Leer CSV (usa tus columnas: nafn, notendanafn, hopur)
$users = Import-Csv $csvPath

foreach ($u in $users) {

    # TU CSV:
    # nafn = nombre completo
    # notendanafn = username
    # hopur = grupo (Innkaup/Sala/Yfirstjórn)

    $username  = ($u.notendanafn -as [string]).Trim()
    $fullname  = ($u.nafn -as [string]).Trim()
    $deptGroup = ($u.hopur -as [string]).Trim()

    # Validación básica
    if ([string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrWhiteSpace($deptGroup)) {
        Write-Host "Fila inválida en CSV, falta notendanafn o hopur. Saltando..." -ForegroundColor Yellow
        continue
    }

    # Crear usuario si no existe
    if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $username -FullName $fullname -Password $securePassword | Out-Null
        Write-Host "Creado: $username" -ForegroundColor Green
    } else {
        Write-Host "Ya existe: $username"
    }

    # Meter al grupo de departamento
    try { Add-LocalGroupMember -Group $deptGroup -Member $username -ErrorAction Stop } catch { }

    # Meter a Allir
    try { Add-LocalGroupMember -Group "Allir" -Member $username -ErrorAction Stop } catch { }
}

Write-Host ""
Write-Host "LISTO. Password para todos: $plainPassword" -ForegroundColor Cyan
