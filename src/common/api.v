module common

import net.http
import json
import readline

pub interface Package {
	install(string)
}

pub struct ArchResponse {
pub mut:
	results []ArchPackage
}

pub struct ArchPackage {
pub mut:
	pkgname string
	repo string
	arch string
	pkgver string
	pkgdesc string
	maintainers []string
	licenses []string
	dependencies []string @[json: depends]
	compressed_size u64
	installed_size u64
	installed bool
}

pub fn (pkg ArchPackage) install(p string) {
	system("echo ${p} | sudo -k -S pacman --noconfirm -Sy ${pkg.pkgname}")
	readline.read_line("Press Enter...") or { "" }

}

pub fn fetch_from_arch(query string, limit int, page int) []ArchPackage {
	mut req_uri := "https://archlinux.org/packages/search/json/"

	if query == "" {
		req_uri += "?limit=${limit}&page=${page}"
	}
	else {
		req_uri += "?q=${query}&limit=${limit}&page=${page}"
	}

	json_text := http.get_text(req_uri)
	structed := json.decode(ArchResponse, json_text) or { ArchResponse{results: []} }

	return structed.results
}