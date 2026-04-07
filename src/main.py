import subprocess
import os
import sys
import json
import ctypes

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def get_resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    
    # Try both original relative path and scripts/config subfolders
    path = os.path.join(base_path, relative_path)
    if os.path.exists(path):
        return path
    
    return path # Fallback to default

def run_powershell(script_name, args=None):
    script_path = get_resource_path(os.path.join("scripts", script_name))
    
    # Se não existir na pasta scripts/, tenta na raiz do bundle
    if not os.path.exists(script_path):
        script_path = get_resource_path(script_name)

    print(f"--- Executando: {script_name} ---")
    
    cmd = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script_path]
    if args:
        cmd.extend(args)
    
    try:
        result = subprocess.call(cmd)
        return result == 0
    except Exception as e:
        print(f"Erro ao executar {script_name}: {e}")
        return False

def main():
    # 1. Verificar Elevação
    if not is_admin():
        print("Solicitando permissões de administrador...")
        # Re-executa o script com privilégios de administrador
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
        sys.exit()

    print("======================================================")
    print("      Instalador de Programas Padrão Windows         ")
    print("======================================================")

    # 2. Carregar Configuração
    config_path = get_resource_path(os.path.join("config", "apps.json"))
    if not os.path.exists(config_path):
        config_path = get_resource_path("apps.json")

    packages = []
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
            packages = config.get("packages", [])
    except Exception as e:
        print(f"Erro ao carregar apps.json: {e}")

    # 3. Fluxo de Execução
    
    # Passo 1: Chocolatey
    if not run_powershell("init_choco.ps1"):
        print("Aviso: Falha ao inicializar o Chocolatey. Algumas instalações podem falhar.")

    # Passo 2: Instalar Programas
    if packages:
        # Passa a lista de pacotes como argumentos para o PowerShell
        run_powershell("install_apps.ps1", ["-Packages", ",".join(packages)])
    else:
        print("Nenhum pacote encontrado para instalar.")

    # Passo 3: Configurações do Sistema
    run_powershell("sys_config.ps1")

    # Passo 4: Atualizações do Windows
    print("\nDeseja buscar atualizações do Windows agora? (S/N)")
    update_choice = input().strip().lower()
    if update_choice == 's':
        run_powershell("win_updates.ps1")

    print("\n======================================================")
    print("             Processo Finalizado com Sucesso!        ")
    print("======================================================")
    input("Pressione Enter para sair...")

if __name__ == "__main__":
    main()
