function subjects = gcp_subject_inclusion(subjects, paths)
inc = load(fullfile(paths.controls, 'GCP_subject_inclusion.mat'), 'subject_inclusion');
inc = inc.subject_inclusion;
sid = str2double(string(subjects));
[~, loc] = ismember(sid, inc.SubjID);
subjects = subjects(inc.Include(loc));
