module pref

import os

pub enum Mods {
	compile
	read
}

[heap]
pub struct Preferences {
pub mut:
	paths		[]string	//папки с файлами для компиляции
	out_dir		[]string	//папки для результата
	mode		Mods
	no_cache	bool
}

fn (mut p Preferences) parse_compile_args(args []string) {
	if args.len < 3  {
		error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
	}

	mut i := 1

	for i < args.len {
		match args[i] {
			"-nocache" {
				p.no_cache = true
				i++
				continue
			}
			"-input" {
				i++
				
				for i < args.len {
					if args[i].starts_with("-") {
						i--
						break
					}

					path := args[i]
					
					if !os.is_dir(path) {
						error("invalid input path: '$path'")
					}

					p.paths << path

					i++
				}
			}
			"-output" {
				i++
				
				for i < args.len {
					if args[i].starts_with("-") {
						break
					}

					path := args[i]

					if !os.is_dir(path) {
						error("invalid output path: '$path'")
					}

					p.out_dir << path

					i++
				}
			}
			else {
				error("invalid argument `${args[i]}`")
			}
		}

		i++
	}
}

pub fn parse_args() Preferences {
	
	mut p := Preferences{}

	if os.args.len <= 1 {
		error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
	}

	args := os.args[1..]

	match args[0] {
		"-compile" {
			p.mode = .compile
			p.parse_compile_args(args)
		}
		"-read" {
			if args.len < 2 {
				error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
			}

			p.mode = .read
			p.paths << args[1]
		}
		else {
			error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
		}
	}

	return p
}

pub fn should_compile_filtered_files(dir string, files_ []string) []string {
	mut files := files_.clone()
	files.sort()

	mut all_v_files := []string{}

	for file in files {
		if !file.ends_with('.psc') {
			continue
		}

		all_v_files << os.join_path(dir, os.file_name(file))
	}

	return all_v_files
}

fn error(msg string) {
	eprintln(msg)
	eprintln("papyrus.exe -compile <input-path> <output-path>")
	exit(1)
}