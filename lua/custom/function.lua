-- Add this in your init.lua or somewhere in your config
vim.api.nvim_create_user_command('CreateCompileFlags', function()
  local file = io.open('compile_flags.txt', 'w')
  if file then
    file:write("-I../c_modules/include\n")
    file:write("-i../c_modules/libs\n")
    file:write("-IC:/ProgramData/mingw64/mingw64/lib/gcc/x86_64-w64-mingw32/13.2.0/include\n")
    file:write("-IC:/ProgramData/mingw64/mingw64/lib/gcc/x86_64-w64-mingw32/13.2.0/include-fixed\n")
    file:write("-IC:/ProgramData/mingw64/mingw64/x86_64-w64-mingw32/include\n")
    file:write("-ic:/programdata/mingw64/mingw64/include\n")
    file:write("-target\n")
    file:write("x86_64-pc-windows-gnu\n")
    file:write("-std=c11\n")
    file:write("-Wall\n")
    file:write("-Wextra\n")
    file:close()
    print("compile_flags.txt created successfully!")
  else
    print("Failed to create compile_flags.txt")
  end
end, {})


vim.api.nvim_create_user_command('CreateMakefile', function()
  local file = io.open('Makefile', 'w')
  if file then
    file:write("CC=gcc\n")
    file:write("CFLAGS= -I ../c_modules/include -Wall -O2\n")
    file:write("LDFLAGS=-L ../c_modules/libs -lm\n")
    file:write("LINKFLAGS = -lraylib -lopengl32 -lgdi32 -lwinmm\n")
    file:write("SRC=src/main.c\n")
    file:write("OUT=build/my_program.exe\n")
    file:write("all:\n")
    file:write("	$(CC) $(SRC) -o $(OUT) $(CFLAGS) $(LDFLAGS) $(LINKFLAGS)\n")
    file:write("run: all\n")
    file:write("	./$(OUT)\n")
    file:write("clean:\n")
    file:write("	rm -f $(OUT)\n")
    file:close()
    print("Makefile created successfully!")
  else
    print("Failed to create Makefile")
  end
end, {})


vim.api.nvim_create_user_command('CreateFolders', function()
  local src_path = "src"
  vim.uv.fs_mkdir(src_path, 493)
  local build_path = "build"
  vim.uv.fs_mkdir(build_path, 493)
  print("Folders created successfully!")
end, {})


vim.api.nvim_create_user_command('CreateCProject', function()
  local file_CC = io.open('compile_flags.txt', 'w')
  if file_CC then
    file_CC:write("-I../c_modules/include\n")
    file_CC:write("-I../c_modules/libs\n")
    file_CC:write("-IC:/ProgramData/mingw64/mingw64/lib/gcc/x86_64-w64-mingw32/13.2.0/include\n")
    file_CC:write("-IC:/ProgramData/mingw64/mingw64/lib/gcc/x86_64-w64-mingw32/13.2.0/include-fixed\n")
    file_CC:write("-IC:/ProgramData/mingw64/mingw64/x86_64-w64-mingw32/include\n")
    file_CC:write("-ic:/programdata/mingw64/mingw64/include\n")
    file_CC:write("-target\n")
    file_CC:write("x86_64-pc-windows-gnu\n")
    file_CC:write("-std=c11\n")
    file_CC:write("-Wall\n")
    file_CC:write("-Wextra\n")
    file_CC:close()
    print("compile_flags.txt created successfully!")
  else
    print("Failed to create compile_flags.txt")
  end

  local file_MF = io.open('Makefile', 'w')
  if file_MF then
    file_MF:write("CC=gcc\n")
    file_MF:write("CFLAGS= -I ../c_modules/include -Wall -O2\n")
    file_MF:write("LDFLAGS=-L ../c_modules/libs -lm\n")
    file_MF:write("LINKFLAGS = -lraylib -lopengl32 -lgdi32 -lwinmm\n")
    file_MF:write("SRC=src/main.c\n")
    file_MF:write("OUT=build/my_program.exe\n")
    file_MF:write("all:\n")
    file_MF:write("	$(CC) $(SRC) -o $(OUT) $(CFLAGS) $(LDFLAGS) $(LINKFLAGS)\n")
    file_MF:write("run: all\n")
    file_MF:write("	./$(OUT)\n")
    file_MF:write("clean:\n")
    file_MF:write("	rm -f $(OUT)\n")
    file_MF:close()
    print("Makefile created successfully!")
  else
    print("Failed to create Makefile")
  end

  local src_path = "src"
  vim.uv.fs_mkdir(src_path, 493)
  local build_path = "build"
  vim.uv.fs_mkdir(build_path, 493)
  print("Folders created successfully!")

end, {})




vim.api.nvim_create_user_command('Crun', function()
  vim.cmd('!make run')
end, {})


--Godot specific functions
vim.api.nvim_create_user_command("Godot", function()
  vim.fn.jobstart({ "E:/Godot/Godot_v4.5.1-stable_win64.exe", "--editor" }, { detach = true })
end, {})

