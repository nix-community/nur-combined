use std::io::Read;
use rusqlite::{Connection, OpenFlags};
// use OpenFlags::*;

fn parse_ascii_bytes(bytes: &[u8]) -> Result<i64, anyhow::Error> {
    let s = std::str::from_utf8(&bytes)?;
    let num = s.trim().parse::<i64>()?;
    Ok(num)
}

fn main() -> Result<(), anyhow::Error> {
    let db_path = std::env::var_os("VACU_HISTORY_DB_PATH").unwrap();
    let session_id = std::env::var("VACU_HISTORY_SESSION_ID").unwrap();
    // expect on stdin the exact output of HISTTIMEFORMAT='%S|%M|%H|%d|%m|%Y|%w|%j|%z|' history 1
    // example output: `  550  53|05|14|20|05|2025|2|140|-0700|echo example`
    let mut hist_output = Vec::with_capacity(4096);
    std::io::stdin().read_to_end(&mut hist_output)?;
    let mut cur_slice = &hist_output[..];
    // the final newline is not part of the command, but any other newlines are
    assert_eq!(cur_slice.last(), Some(&b'\n'));
    cur_slice = &cur_slice[..cur_slice.len()-1];
    while let Some(b' ') = cur_slice.first() {
        cur_slice = &cur_slice[1..];
    }
    let Some(idx) = cur_slice.iter().position(|&b| b == b' ') else { panic!() };
    let (history_index_digits, new_slice) = cur_slice.split_at(idx);
    cur_slice = new_slice;
    let history_num = parse_ascii_bytes(history_index_digits)?;
    while let Some(b' ') = cur_slice.first() {
        cur_slice = &cur_slice[1..];
    }
    let pieces:Vec<&[u8]> = cur_slice.splitn(10, |b| *b == b'|').collect();
    if pieces.len() != 10 { panic!() }

    let conn = Connection::open_with_flags(
        db_path,
        OpenFlags::SQLITE_OPEN_READ_WRITE | OpenFlags::SQLITE_OPEN_CREATE | OpenFlags::SQLITE_OPEN_EXRESCODE | OpenFlags::SQLITE_OPEN_NO_MUTEX
    )?;

    conn.execute(r#"
        create table if not exists command_history (
            session_id text not null,
            history_index int not null,
            seconds int not null,
            minutes int not null,
            hours int not null,
            day_of_month int not null,
            month int not null,
            year int not null,
            day_of_week int not null,
            day_of_year int not null,
            timezone text not null,
            command blob not null
        )
    "#, ())?;

    let maybe_nums:Result<Vec<i64>,_> = pieces[0..=7].iter().copied().map(parse_ascii_bytes).collect();
    let nums = maybe_nums?;
    let tz = std::str::from_utf8(pieces[8])?;

    conn.execute(
        concat!(
        "insert into command_history ",
        "(session_id, history_index,  seconds,  minutes,  hours,    day_of_month, month,    year,     day_of_week, day_of_year, timezone,   command) values ",
        "(?1,         ?2,             ?3,       ?4,       ?5,       ?6,           ?7,       ?8,       ?9,          ?10,         ?11,        ?12)"
        ),
        (&session_id, &history_num,   &nums[0], &nums[1], &nums[2], &nums[3],     &nums[4], &nums[5], &nums[6],    &nums[7],    &tz,        &pieces[9])
    )?;

    Ok(())
}
