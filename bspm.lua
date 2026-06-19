#!/usr/bin/env lua

-- define things

--# General
local args = { ... }

local sudo = "sudo"      -- sudo by default since it's more common. Can be changed to ex. doas
local aurhelper = "paru" -- paru by default because it's seriously time we switch to paru from yay guys

local command = args[1]
local package = args[2]

local version = "Concept v0.1"

local function PrintInfo()
  print("Barely a Source Package Manager, " .. version .. "")
  os.execute("echo")
  print(
    "At this stage of the package manager, it doesn't really do much and is very opinionated. The install argument works, but the -r flag does not resolve dependencies. The only reason the install argument does resolve dependencies is because all it does is call an AUR helper that does so already.")
  os.execute("echo")
  print(
    "As of now, this package manager only supports Makefile instructions which must compile as it should using just 'make', and also contain instructions for 'install', in order to function properly.")
  os.execute("echo")
  print(
    "That said, this is only a concept version of a project where I'm only trying to return to programming after a few years of not doing it properly and trying to dig deeper into how Linux distributions really work.")
  os.execute("echo")
end

local function PrintUsage()
  print("Usage:")
  print("bspm install [package] (installs package via AUR)")
  print("bspm install -r [link] (installs package via link, assumes 'https://')")
  print("bspm install -l [full repository URL] (installs package via link, doesn't assume 'https://')") -- not sure how I would implement this. Help?
  print("bspm clear (clears bspm's downloaded repositories)")
  print("bspm makedirs (prepares needed directories)")
end

--# Install logic

local function install_from_aur(pkg)
  os.execute(aurhelper .. " -S " .. pkg)
end

local function install_from_git(url)
  local path = os.getenv("HOME") .. "/.cache/bspm/builds/repo"

  os.execute("rm -rf " .. path)
  os.execute("git clone " .. url .. " " .. path)

  os.execute("make -C " .. path)
  os.execute(sudo .. " make -C " .. path .. " install")
end

-- actual code (now I'm a true programmer lol)

if command == "makedirs" then
  os.execute("mkdir -p ~/.cache/bspm/builds/")
end

if command == "clear" then
  print("Are you sure you want to clear ~/.cache/bspm? (You can press 'i' to inspect command used to clear) [Y/n/i]")

  local input = io.read()

  if input == "Y" or input == "y" or input == "" then
    os.execute("rm -rf ~/.cache/bspm/")
    os.execute("mkdir -p ~/.cache/bspm/")
  elseif input == "I" or input == "i" then
    print("-> rm -rf ~/.cache/bspm/")
    print("-> mkdir -p ~/.cache/bspm/")
  else
    print("Ok.")
  end
end


if command == nil then
  PrintInfo()
  PrintUsage()
end

if command == "install" then
  local is_git = false
  local repo_url = nil
  package = nil

  for i = 2, #args do
    if args[i] == "-r" then
      if not args[i + 1] then
        print("Missing repo link")
        return
      end

      is_git = true
      repo_url = "https://" .. args[i + 1]
    elseif args[i] == "-l" then
      is_git = true
      repo_url = args[i + 1]
    elseif args[i - 1] ~= "-r" and args[i - 1] ~= "-l" then
      package = args[i]
    end
  end

  if is_git then
    if not repo_url or repo_url == "https://" then
      print("Missing repo URL")
      return
    end
    install_from_git(repo_url)
  else
    if not package then
      PrintUsage()
      return
    end
    install_from_aur(package)
  end
end
