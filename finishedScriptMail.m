function finishedScriptMail()
% finishedScriptMail sends an email using MATLAB's sendmail function.
% This function always sends the email to arne.hansen@psychologie.uzh.ch.
% The subject is automatically generated from the title of the calling script
% followed by " - FINISHED".
%
% Input:
%   message - body of the email as a string.
%
% Example usage:
%   finishedScriptMail('Script execution completed.');

% Set recipient
recipient = 'arne96.hansen@gmail.com';

% Determine the subject by retrieving the calling script's or function's name
try
    currentFile = matlab.desktop.editor.getActiveFilename;
    [~, scriptName, ~] = fileparts(currentFile);
catch
    scriptName = 'UnknownScript';
end
subject = [scriptName, ' - FINISHED'];

% Check if sendmail is configured
if isempty(getpref('Internet','SMTP_Server')) || isempty(getpref('Internet','E_mail'))
    warning('sendmail is not configured. Please set preferences using setpref before using this function.');
    return;
end

try
    % Attempt to send the email
    sendmail(recipient, subject);
    fprintf('Email sent successfully to %s with subject "%s".\n', recipient, subject);
catch ME
    % If an error occurs, display the error message
    fprintf('Failed to send email: %s\n', ME.message);
end
end
