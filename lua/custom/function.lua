-- Add this in your init.lua or somewhere in your config
vim.api.nvim_create_user_command('CreateCompileFlags', function()
  local file = io.open('compile_flags.txt', 'w')
  if file then
    file:write("-I../c_modules/include\n")
    file:write("-I../c_modules/libs\n")
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
  local inlude_path = "include"
  vim.uv.fs_mkdir(inlude_path, 493)
  local libs_path = "libs"
  vim.uv.fs_mkdir(libs_path, 493)
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

  local inlude_path = "include"
  vim.uv.fs_mkdir(inlude_path, 493)
  local libs_path = "libs"
  vim.uv.fs_mkdir(libs_path, 493)
  local src_path = "src"
  vim.uv.fs_mkdir(src_path, 493)
  local build_path = "build"
  vim.uv.fs_mkdir(build_path, 493)
  print("Folders created successfully!")

end, {})
