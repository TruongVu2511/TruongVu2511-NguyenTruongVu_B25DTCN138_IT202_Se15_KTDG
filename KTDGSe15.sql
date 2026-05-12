drop database StudentManagement;
create database StudentManagement;
use StudentManagement;

create table students(
student_id	VARCHAR(5)	PRIMARY KEY,
full_name	VARCHAR(50)	NOT NULL,
total_debt	DECIMAL(10,2) DEFAULT 0
);

create table subjects(
subject_id	VARCHAR(5)	PRIMARY KEY,
subject_name VARCHAR(50) NOT NULL,
credits	INT	CHECK (credits > 0)
);

create table grades(
student_id	VARCHAR(5), 
subject_id	VARCHAR(5),
score	DECIMAL(4,2)	CHECK (score BETWEEN 0 AND 10),
PRIMARY KEY (student_id, subject_id),
FOREIGN KEY (student_id) references students(student_id),
FOREIGN KEY (subject_id) references subjects(subject_id)
);

create table grade_log(
log_id	INT AUTO_INCREMENT PRIMARY KEY,
student_id	VARCHAR(5),
old_score	DECIMAL(4,2),
new_score	DECIMAL(4,2),
change_date	DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (student_id) references students(student_id)
);
-- Cau 1
delimiter //
create trigger tg_check_score 
before insert on grades
for each row
begin 
if new.score < 0 then 
set new.score = 0 ;
elseif new.score > 10 then
set new.score = 10 ;
end if;
end //
delimiter ;

-- Cau 2
start transaction ;
insert into students(student_id, full_name)
values ( 'SV02',  'Ha Bich Ngoc');
update students
set total_debt = 5000000
where student_id = 'SV02';
commit;

-- Cau 3
delimiter //
create trigger tg_log_grade_update 
after update on grades 
for each row 
begin 
	if old.score <> new.score then
    insert into grade_log (student_id, old_score, new_score, change_date)
    values (new.student_id, old.old_score, new.new_score, new.now(change_date) );
    end if;
end //
delimiter ;

-- Cau 4
delimiter //
create procedure sp_pay_tuition()
begin 
	start transaction;
    update students
    set total_debt = total_debt - 2000000
    where student_id = 'SV01';
    if total_debt < 0 then 
    rollback ;
    else 
    commit ;
    end if ;
end //
delimiter ;

-- Cau 5
delimiter //
create trigger tg_prevent_pass_update
before update on grades 
for each row 
begin 
	if old.score >= 4.0 then 
    signal sqlstate '45000'
    set message_text = 'Lỗi : Không được phép sửa điểm ';
    end if ;
end //
delimiter ;

