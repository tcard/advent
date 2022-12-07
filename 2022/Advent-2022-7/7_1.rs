use std::collections::HashMap;

fn main() {
    let mut commands = std::io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .filter(|line| line.len() > 0)
        .map(|line| Input::parse(&line));

    let mut root: HashMap<String, DirEntry> = HashMap::new();

    populate_fs(&mut root, &mut commands);

    let sizes = dir_sizes(&root);

    let solution = sizes
        .into_iter()
        .filter(|size| *size < 100_000)
        .sum::<u64>();

    println!("{}", solution);
}

struct Done;

fn populate_fs(
    entries: &mut HashMap<String, DirEntry>,
    commands: &mut dyn Iterator<Item = Input>,
) -> Option<Done> {
    loop {
        match commands.next() {
            Some(Input::Cd(name)) => {
                let mut entry = entries.entry(name.clone()).or_insert_with(|| {
                    DirEntry::Dir(Dir {
                        name: name.clone(),
                        entries: HashMap::new(),
                    })
                });
                if let DirEntry::Dir(dir) = &mut entry {
                    if let Some(Done) = populate_fs(&mut dir.entries, commands) {
                        return Some(Done);
                    }
                }
            }

            Some(Input::CdParent) => {
                return None;
            }

            Some(Input::Ls | Input::CdRoot) => {
                continue;
            }

            Some(Input::File(File { name, size })) => {
                entries.insert(
                    name.clone(),
                    DirEntry::File(File {
                        name: name.clone(),
                        size,
                    }),
                );
            }

            Some(Input::Dir(name)) => {
                entries.insert(
                    name.clone(),
                    DirEntry::Dir(Dir {
                        name: name.clone(),
                        entries: HashMap::new(),
                    }),
                );
            }

            _ => {
                return Some(Done);
            }
        }
    }
}

fn dir_sizes(entries: &HashMap<String, DirEntry>) -> Vec<u64> {
    fn dir_sizes_inner(entries: &HashMap<String, DirEntry>, sizes: &mut Vec<u64>) -> u64 {
        let mut sum: u64 = 0;
        for entry in entries.values() {
            match entry {
                DirEntry::File(File { size, .. }) => {
                    sum += size;
                }
                DirEntry::Dir(Dir { entries, .. }) => {
                    sum += dir_sizes_inner(entries, sizes);
                }
            }
        }
        sizes.push(sum);
        return sum;
    }

    let mut sizes: Vec<u64> = vec![];
    dir_sizes_inner(&entries, &mut sizes);
    return sizes;
}

#[derive(Debug)]
enum DirEntry {
    File(File),
    Dir(Dir),
}

#[derive(Debug)]
struct File {
    name: String,
    size: u64,
}

#[derive(Debug)]
struct Dir {
    name: String,
    entries: HashMap<String, DirEntry>,
}

#[derive(Debug)]
enum Input {
    Cd(String),
    CdParent,
    CdRoot,
    Ls,
    File(File),
    Dir(String),
}

impl Input {
    fn parse(src: &str) -> Self {
        let parts: Vec<_> = src.split(" ").collect();
        match parts.as_slice() {
            &["$", "cd", ".."] => Self::CdParent,
            &["$", "cd", "/"] => Self::CdRoot,
            &["$", "cd", dir_name] => Self::Cd(dir_name.to_string()),
            &["$", "ls"] => Self::Ls,
            &["dir", dir_name] => Self::Dir(dir_name.to_string()),
            &[size, file_name] => Self::File(File {
                name: file_name.to_string(),
                size: size.parse().unwrap(),
            }),
            other => panic!("unexpected input: {:?}", other),
        }
    }
}
