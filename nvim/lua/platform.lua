-- Change shell to powershell if on Windows
if vim.fn.has('win32') == 1 then
    vim.o.shell = "powershell.exe"
    vim.o.shellxquote = ""
    vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    vim.o.shellquote = ""
    vim.o.shellpipe = "| Out-File -Encoding UTF8 %s"
    vim.o.shellredir = "| Out-File -Encoding UTF8 %s"
end


