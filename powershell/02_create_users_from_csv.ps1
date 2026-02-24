# Ejecutar PowerShell como Administrador
$csvPath = ".\users.csv"

# Contraseña para todos (para el proyecto)
$plainPassword = "Passw0rd!2024"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

$users = Import-Csv $csvPath

foreach ($u in $users) {
    $username = $u.Username.Trim()
    $fullname = $u.FullName.Trim()
    $deptGroup = $u.DepartmentGroup.Trim()

    if (-not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $username -FullName $fullname -Password $securePassword
        Write-Host "Creado: $username"
    } else {
        Write-Host "Ya existe: $username"
    }

    # meter en su grupo de departamento
    try { Add-LocalGroupMember -Group $deptGroup -Member $username -ErrorAction Stop } catch {}
    # meter en Allir
    try { Add-LocalGroupMember -Group "Allir" -Member $username -ErrorAction Stop } catch {}
}

Write-Host "LISTO. Password para todos: $plainPassword"
