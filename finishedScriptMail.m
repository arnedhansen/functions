function finishedScriptMail(message)
    % sendMyMessage sends an email using MATLAB's sendmail function.
    % This function always sends the email to arne.hansen@psychologie.uzh.ch.
    % The subject is automatically generated from the title of the calling script
    % followed by " - FINISHED".
    %
    % Input:
    %   message - body of the email as a string.
    %
    % Example usage:
    %   sendMyMessage('This is a test email from MATLAB.');
    
    % Set recipient
    recipient = 'arne.hansen@psychologie.uzh.ch';
    
    % Determine the subject by retrieving the calling script's name
    stackInfo = dbstack('-completenames');
    if numel(stackInfo) >= 2
        % The calling script is the second entry in the stack
        [~, scriptName, ~] = fileparts(stackInfo(2).file);
        subject = [scriptName, ' - FINISHED'];
    else
        % Fallback subject if no caller is found
        subject = 'MATLAB Script - FINISHED';
    end
    
    % Ensure that your email preferences have been set before running this function.
    % Example configuration:
    % setpref('Internet','E_mail','your_email@example.com')
    % setpref('Internet','SMTP_Server','smtp.example.com')
    % setpref('Internet','SMTP_Username','your_email@example.com')
    % setpref('Internet','SMTP_Password','yourpassword')
    
    try
        % Attempt to send the email
        sendmail(recipient, subject, message);
        fprintf('Email sent successfully to %s with subject "%s".\n', recipient, subject);
    catch ME
        % If an error occurs, display the error message
        fprintf('Failed to send email: %s\n', ME.message);
    end
end
