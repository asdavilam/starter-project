Firestore Database Schema – Articles

Overview

This document describes the Firestore database schema used to store articles created and managed by journalists within the Applicant Showcase App.

The schema is inspired by the data structure currently used by the external News API but has been adapted to meet the requirements of a scalable, secure, and production-ready NoSQL backend using Firebase Firestore and Firebase Cloud Storage.

⸻

Collection Structure

Root Collections
	•	articles
Stores all articles created by journalists.

⸻

Article Document

Each document inside the articles collection represents a single article.

Collection Path

/articles/{articleId}

Where articleId is an auto-generated Firestore document ID.

⸻

Article Schema

Field Name
Type
Required
Description
id
number
No
Optional numeric identifier originating from external APIs. Firestore document ID is used as the primary identifier.
author
string
Yes
Name of the article author or journalist.
title
string
Yes
Article headline or title.
description
string
No
Short summary or teaser of the article.
content
string
Yes
Full article content body.
url
string
No
Public URL where the article can be accessed (if applicable).
thumbnailURL
string
Yes
Reference URL pointing to an image stored in Firebase Cloud Storage under media/articles/.
publishedAt
timestamp
Yes
Date and time when the article was published.
createdAt
timestamp
Yes
Date and time when the article was created in Firestore.
updatedAt
timestamp
Yes
Date and time of the last article update.
isPublished
boolean
Yes
Indicates whether the article is publicly visible.
isVisibleToPublic
boolean
Yes
Indicates whether the article is visible to public users. Provides additional visibility control beyond isPublished status.
source
string
No
Origin of the article (e.g., “internal”, “api”, “manual”).

Firebase Cloud Storage Structure

Article thumbnails are stored in Firebase Cloud Storage and referenced from Firestore.

Storage Path Convention

/media/articles/{articleId}/thumbnail.jpg

Only the download URL of the stored image is saved in the thumbnailURL field inside the Firestore document.

⸻

Data Consistency Rules
	•	Firestore document ID is considered the authoritative identifier.
	•	The id field is optional and should only be used for backward compatibility with external APIs.
	•	All timestamps (createdAt, updatedAt, publishedAt) must be generated server-side when possible.
	•	Article content must never be stored in Firebase Cloud Storage; only media files are allowed.
	•	Deleting an article should also trigger deletion of its associated media in Cloud Storage.

⸻

Indexing Considerations

The following fields are expected to be indexed for querying and ordering:
	•	publishedAt
	•	createdAt
	•	isPublished
	•	isVisibleToPublic
	•	author

Composite indexes may be required for queries such as:
	•	Fetching published articles ordered by date
	•	Filtering articles by author and publication status
	•	Filtering by isPublished and isVisibleToPublic with date ordering

⸻

Future Extensions

This schema is designed to be extensible. Possible future enhancements include:
	•	Adding article categories or tags
	•	Supporting multiple images per article
	•	Introducing user roles and permissions
	•	Adding article revision history

⸻

Summary

This schema balances simplicity and scalability while maintaining compatibility with the existing News API structure. It allows journalists to create, manage, and publish articles efficiently while enforcing clear separation between structured data (Firestore) and media assets (Cloud Storage).